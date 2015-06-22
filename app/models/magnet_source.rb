# describes magnet source from piratebay
class MagnetSource < ActiveRecord::Base
  validates_presence_of :magnet_keyword
  validates_uniqueness_of :magnet_keyword, scope: :category,
                                           case_sensitive: false

  belongs_to :keyword
  has_many :magnets

  after_create :import_async

  def self.import!(id)
    find(id).import
  end

  def import
    1.upto(number_of_pages) { |page| import_page(page) }
  end

  def self.find_or_create!(attributes)
    record = find_by(
      category: attributes[:category],
      magnet_keyword: attributes[:magnet_keyword]
    ) || new
    record.attributes = attributes
    record.category = attributes[:category]
    record.magnet_keyword = attributes[:magnet_keyword]
    record.save!
  end

  private

  def import_page(page)
    fetch_results(page).each do |result|
      torrent_details = TorrentDetails.new(result[:torrent_id])
      result.merge!(
        files: torrent_details.files,
        size: torrent_details.size,
        uploaded: torrent_details.uploaded,
        description: torrent_details.description,
      )
      magnets.create_or_update_by_torrent_id(result)
    end
  end

  def fetch_results(page)
    pirate_bay_search(page).results
  end

  def pirate_bay_search(page)
    ThePirateBay::Search.new(magnet_keyword, page, sort_by, category, true)
  end

  def import_async
    MagnetSourceImportWorker.perform_async(id)
  end
end
