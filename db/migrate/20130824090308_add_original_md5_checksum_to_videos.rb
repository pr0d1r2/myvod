class AddOriginalMd5ChecksumToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :original_md5_checksum, :string, :limit => 40
  end
end
