class AddAttachmentVideoToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :videos, :video
  end
end
