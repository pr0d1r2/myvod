# storage for bad keywords for which stuff is not considered
class BadWord < ActiveRecord::Base
  before_validation :set_word_downcase

  validates_presence_of :word
  validates_uniqueness_of :word

  private

  def set_word_downcase
    self.word = word.to_s.downcase
  end
end
