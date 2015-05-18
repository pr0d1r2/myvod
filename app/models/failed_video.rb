# model containing md5 sums of failed videos
# to not try to import files failed once
class FailedVideo < ActiveRecord::Base
  validates_length_of :md5, is: 32

  def self.from_file(path)
    md5 = Digest::MD5.hexdigest(File.read(path))
    find_or_create_by(md5: md5)
  end
end
