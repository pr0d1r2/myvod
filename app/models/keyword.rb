# keywords storage and autocreate of magnet sources
class Keyword < ActiveRecord::Base
  VALID_CATEGORIES = [
    ThePirateBay::Category::Audio.to_i,
    101, 102, 103, 104, 199,
    ThePirateBay::Category::Video.to_i,
    201, 202, 203, 204, 205, 206, 207, 208, 209, 299,
    ThePirateBay::Category::Applications.to_i,
    301, 302, 303, 304, 305, 306, 399,
    ThePirateBay::Category::Games.to_i,
    401, 402, 403, 404, 405, 406, 407, 408, 499,
    500,
    501, 502, 503, 504, 505, 506, 599,
    600,
    601, 602, 603, 604, 605, 606, 699
  ]

  serialize :categories

  validates_presence_of :keyword
  validates_uniqueness_of :keyword

  validate :categories_valid

  after_save :create_magnet_sources

  has_many :magnet_sources

  private

  def categories_valid
    unless categories.present? &&
           categories.reject do |category|
             VALID_CATEGORIES.include?(category)
           end.empty?
      errors.add :categories,
                 "Must contain at least one of: #{VALID_CATEGORIES.join(', ')}"
    end
  end

  def create_magnet_sources
    categories.map do |category|
      magnet_source = magnet_source_for_category(category)
      magnet_source.category = category
      magnet_source.magnet_keyword = keyword
      magnet_source.sort_by = ThePirateBay::SortBy::Relevance
      magnet_source.number_of_pages = 10
      magnet_source.save!
    end
  end

  def magnet_source_for_category(category)
    magnet_sources.find_by_category_and_magnet_keyword(category, keyword) ||
      magnet_sources.new
  end
end
