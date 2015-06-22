# describes single video imported into system
class Video < ActiveRecord::Base # rubocop:disable ClassLength
  acts_as_paranoid

  include FlagShihTzu
  include AwesomeFlags

  has_flags 1 => :like,
            2 => :seen,
            3 => :best

  APPLE_CONVERT_DEFAULTS = {
   output: {
     acodec: 'aac',
     ac: 2,
     strict: 'experimental',
     ab: '128k',
     vcodec: 'libx264',
     vprofile: 'baseline',
     preset: 'ultrafast', # use dont use slow as this is preview video
     level: 13,
     maxrate: 900_000,
     bufsize: 3_000_000,
     f: 'mp4',
     b: '900k',
     r: 29,
     fflags: '+genpts',
     threads: 0
    }.merge('profile:v' => 'baseline')
  }

  APPLE_STYLE_DEFAULTS = {
   format: 'mp4',
   streaming: true,
   whiny: true,
   convert_options: APPLE_CONVERT_DEFAULTS
  }

  FORMATS = {
    # iphone4: '960x640',
    # iphone: '640x480',
   ipod: '480x320'
  }

  THUMB_COUNT = 24
  THUMB_INDEX = 15

  THUMB_PERCENTILE = 100.0 / THUMB_COUNT

  THUMBNAILS = 1.upto(THUMB_COUNT).map { |number| "thumb#{number}".to_sym }

  INDEX_THUMBNAIL = THUMBNAILS[THUMB_INDEX]

  THUMB_DEFAULTS = {
    geometry: '320x240#',
    format: 'jpg'
  }

  has_attached_file :video, # rubocop:disable Lambda
                    processors: [:ffmpeg, :qtfaststart],
                    styles: lambda { |video| video.instance.send(:paperclip_styles) } # rubocop:disable LineLength

  do_not_validate_attachment_file_type :video

  CONVERTABLE_INPUT = %w(avi mp4 m4v wmv mov flv mpg mpeg rm rmvb)

  before_post_process :get_video_duration
  before_validation :get_original_md5_checksum, on: :create
  validates_uniqueness_of :original_md5_checksum, on: :create
  validate :original_md5_checksum_not_in_failed_videos
  validate :not_sample
  after_destroy :video_clear
  before_update :set_like_when_best

  belongs_to :videoable, polymorphic: true

  paginates_per 24

  scope :unseen, -> { # rubocop:disable Lambda
    where(not_seen_condition).order('videos.created_at DESC')
  }

  scope :liked, -> { where(like_condition) }
  scope :bested, -> { where(best_condition) }
  scope :not_liked, -> { where(seen_condition).where(not_like_condition) }
  scope :not_liked_lately, -> { not_liked.where('updated_at < ?', 1.hour.ago) }
  scope :recently_updated, -> { order('videos.updated_at DESC') }

  def get_video_duration
    result = `ffmpeg -i \"#{file_for_write}\" 2>&1`
    if result =~ /Duration: ([\d][\d]:[\d][\d]:[\d][\d].[\d]+)/
      self.duration = Regexp.last_match[1].to_s
    end
    true
  end

  def from_file=(filename)
    self.video = open(filename)
    self.name = File.basename(filename)
  end

  def self.create_from_file(filename, parent_object = nil)
    video = new
    if parent_object
      video.videoable_type = parent_object.class.name
      video.videoable_id = parent_object.id
    end
    video.from_file = filename
    video.save
    video
  end

  def self.create_from_file!(filename, parent_object = nil)
    video = new
    if parent_object
      video.videoable_type = parent_object.class.name
      video.videoable_id = parent_object.id
    end
    video.from_file = filename
    video.save!
    video
  end

  def seconds
    duration.split(':')[0].to_i * 3600 +
    duration.split(':')[1].to_i * 60 +
    duration.split(':')[2].to_i
  end

  def ss(percentage)
    SS.new(seconds).at_percentage(percentage)
  end

  def ss_at_thumbnail_index(index)
    SS.new(seconds_at_thumbnail_index(index)).ss
  end

  def seconds_at_thumbnail_index(index)
    (seconds.to_f / THUMB_COUNT) * index
  end

  def ss_at_detailed_thumb(num)
    SS.new(seconds_at_detailed_thumb(num)).ss
  end

  def seconds_at_detailed_thumb(num)
    60 * (num - 1)
  end

  def self.unseen_count
    unseen.count
  end

  def self.flush_not_liked!
    not_liked_lately.destroy_all
  end

  def non_unique?
    valid?
    errors.messages[:original_md5_checksum] &&
    errors.messages[:original_md5_checksum].include?('has already been taken')
  end

  def is_sample?
    valid?
    errors.messages[:name] &&
    errors.messages[:name].include?(
      'Must not be sample video (name include "sample" && <80s duration)'
    )
  end

  def not_importable?
    non_unique? || is_sample?
  end

  def orginal_streamable?
    orginal_suffix.downcase == 'mp4'
  end

  def seen!
    self.seen = true
    save! if seen_changed?
  end

  def number_of_detailed_thumb_styles
    (seconds / 60.0).ceil
  end

  def detailed_url
    if orginal_streamable?
      video.url(:original)
    else
      video.url(FORMATS.keys.first)
    end
  end

  def detailed_thumbnails
    Hash[
      1.upto(number_of_detailed_thumb_styles).map do |i|
        [seconds_at_detailed_thumb(i), "detailed_thumb#{i}".to_sym]
      end
    ]
  end

  def preview_thumbnails
    Hash[
      THUMBNAILS.each_with_index.map do |thumbnail_name, i|
        [seconds_at_thumbnail_index(i).to_i, thumbnail_name]
      end
    ]
  end

  def all_thumbnails
    Hash[
      detailed_thumbnails.merge(preview_thumbnails).sort
    ]
  end

  def self.best_random
    find(best_random_id)
  end

  def self.best_random_id
    best_ids.sample(1)[0]
  end

  def self.best_ids
    best.map(&:id)
  end

  def self.like_random
    find(like_random_id)
  end

  def self.like_random_id
    like_ids.sample(1)[0]
  end

  def self.like_ids
    like.map(&:id)
  end

  private

  def orginal_suffix
    video(:orginal).split('?').first.split('.').last
  end

    def video_clear
      video.clear
    end

    def get_original_md5_checksum
      self.original_md5_checksum = Digest::MD5.hexdigest(
        File.read(file_for_write)
      )
    end

    def file_for_write
      video.queued_for_write[:original].path
    end

    def set_like_when_best
      self.like = true if best && best_changed?
    end

    def sample?
      seconds < 80 && name.include?('sample')
    end

    def not_sample
      if sample?
        errors.add :name,
                   'Must not be sample video ' +
                   '(name include "sample" && <80s duration)'
      end
    end

    def detailed_thumb_styles
      Hash[
        1.upto(number_of_detailed_thumb_styles).map do |number|
          [
            "detailed_thumb#{number}".to_sym,
            THUMB_DEFAULTS.merge(
              time: ss_at_detailed_thumb(number)
            )
          ]
        end
      ]
    end

    def normal_thumb_styles
      Hash[
        THUMBNAILS.each_with_index.map do |name, i|
          [
            name,
            THUMB_DEFAULTS.merge(
              time: ss(THUMB_PERCENTILE * i)
            )
          ]
        end
      ]
    end

    def video_styles
      Hash[
        FORMATS.map do |name, geometry|
          [
            name,
            APPLE_STYLE_DEFAULTS.merge(geometry: geometry)
          ]
        end
      ]
    end

    def paperclip_styles
      video_styles.merge(normal_thumb_styles).merge(detailed_thumb_styles)
    end

    def original_md5_checksum_not_in_failed_videos
      if FailedVideo.find_by_md5(original_md5_checksum)
        errors.add :md5,
                   'md5 sum of this video already exist in failed videos'
      end
    end
end
