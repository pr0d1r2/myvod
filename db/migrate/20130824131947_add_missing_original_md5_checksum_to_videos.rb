class AddMissingOriginalMd5ChecksumToVideos < ActiveRecord::Migration
  class Video < ActiveRecord::Base
    def update_original_md5_checksum!
      puts "Add missing original_md5_checksum to video ##{id}"
      self.original_md5_checksum = Digest::MD5.hexdigest(File.read(video.path))
      save!
    end
  end

  def change
    Video.where('original_md5_checksum is NULL').find_in_batches(:batch_size => 10) do |videos|
      videos.each(&:update_original_md5_checksum!)
    end
  end
end
