# describes single magnet imported from magnet source
# basis for magnet download
class Magnet < ActiveRecord::Base # rubocop:disable ClassLength
  MINIMUM_FREE_DISK_SPACE = Rails.configuration.magnet_download_finished_dir_free_space # GB # rubocop:disable LineLength

  include FlagShihTzu
  include AwesomeFlags

  has_flags 1 => :like,
            2 => :seen

  include Workflow
  workflow do
    state :new do
      event :downloaded, transitions_to: :downloaded
      event :download_timeout, transitions_to: :download_timeouted
      event :download_error, transitions_to: :download_errored
    end
    state :downloaded
    state :download_timeouted
    state :download_errored
  end

  class DownloadTmpDirectoryError < StandardError; end
  class DownloadFinishedDirectoryError < StandardError; end
  class AlreadyDownloadedError < StandardError; end
  class DownloadErrorPreviouslyError < StandardError; end
  class DownloadTimeoutPreviouslyError < StandardError; end
  class NoSeedersError < StandardError; end
  class LowTotalSeedersError < StandardError; end
  class HasBadWordsError < StandardError; end

  BITTORRENT_OPTIONS = {
    upload_rate_limit: '10000K',
    seed_time: 3600,
    connect_timeout: 600,
    timeout: 600,
    use_tor_proxy: true
  }

  belongs_to :magnet_source
  has_many :videos, as: :videoable

  validates_numericality_of :torrent_id
  validates_uniqueness_of :torrent_id

  after_update :download_when_liked

  scope :value_order, -> { # rubocop:disable Lambda
    order(
      [
        'magnets.seeders DESC',
        'magnets.leechers DESC',
        'magnets.created_at DESC'
      ].join(',')
    )
  }

  scope :unseen, -> { where(not_seen_condition).value_order }

  scope :to_download, -> { where(not_like_condition).unseen }

  scope :batch_to_download, -> { to_download.limit(20) }

  def self.create_or_update_by_torrent_id(attributes)
    record = unscoped.find_by_torrent_id(attributes[:torrent_id]) || new
    record.assign_attributes(attributes)
    if record.save
      true
    else
      unless record.errors.messages[:torrent_id]
                          .include?('has already been taken')
        record.save!
      end
    end
  end

  def assign_attributes(attributes) # rubocop:disable MethodLength
    self.title = attributes[:title]
    self.seeders = attributes[:seeders]
    self.leechers = attributes[:leechers]
    self.magnet_link = attributes[:magnet_link]
    self.torrent_id = attributes[:torrent_id]
    self.category = attributes[:category]
    self.url = attributes[:url]
    self.files = attributes[:files]
    self.size = attributes[:size]
    self.uploaded = attributes[:uploaded]
    self.description = attributes[:description]
  end

  def self.download_timeout!(magnet_id)
    find(magnet_id).download_timeout!
  end

  def self.download_error!(magnet_id)
    find(magnet_id).download_error!
  end

  def self.download!(magnet_id)
    find(magnet_id).download!
  end

  alias_attribute :magnet_link, :link

  def magnet_link=(val)
    self.link = val
  end

  def download!
    detect_download_errors!
    create_download_tmp_directory!
    BitTorrent.download!(link, BITTORRENT_OPTIONS.merge(
      destination_directory: download_tmp_directory
    ))
    post_download!
  end

  def like!
    self.seen = true
    self.like = true
    save!
  end

  def self.enqueue_download!
    batch_to_download.map(&:like!) if have_disk_space?
  end

  private

  def detect_download_errors! # rubocop:disable CyclomaticComplexity
    fail AlreadyDownloadedError if downloaded?
    fail DownloadErrorPreviouslyError if download_errored?
    fail DownloadTimeoutPreviouslyError if download_timeouted?
    fail NoSeedersError if no_seeders?
    fail LowTotalSeedersError if low_total_seeders?
    fail HasBadWordsError if has_bad_words?
  end

  def post_download!
    move_to_finished_download_directory!
    like!
    downloaded!
    VideoDirectoryImportWorker.perform_async(
      download_finished_directory, self.class.name, id
    )
  end

  def self.have_disk_space?
    MagnetTmpDir.have_disk_space? &&
    FreeDiskSpace.gigabytes(
      Rails.configuration.magnet_download_finished_dir
    ) > MINIMUM_FREE_DISK_SPACE
  end

  def create_download_tmp_directory!
    unless FileUtils.mkdir_p(download_tmp_directory)
      fail DownloadTmpDirectoryError, download_tmp_directory
    end
  end

  def move_to_finished_download_directory!
    unless FileUtils.mv(download_tmp_directory, download_finished_directory)
      fail DownloadFinishedDirectoryError, download_finished_directory
    end
  end

  def download_tmp_directory
    "#{MagnetTmpDir::PATH}/#{id}"
  end

  def download_finished_directory
    "#{Rails.configuration.magnet_download_finished_dir}/#{id}"
  end

  def download_when_liked
    if like && like_changed? && !downloaded?
      MagnetDownloadWorker.perform_async(id)
    end
  end

  def seeders?
    seeders > 0
  end

  def no_seeders?
    !seeders?
  end

  def total_seeders
    seeders + leechers
  end

  def low_total_seeders?
    total_seeders < 10
  end

  def has_bad_words?
    BadWord.find_each do |bad_word|
      return true if title.downcase.include?(bad_word.word)
    end
  end
end
