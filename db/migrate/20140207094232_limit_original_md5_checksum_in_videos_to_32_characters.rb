class LimitOriginalMd5ChecksumInVideosTo32Characters < ActiveRecord::Migration
  def change
    change_column :videos, :original_md5_checksum, :string, :limit => 32
  end
end
