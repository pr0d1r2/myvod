class ChangeVideoFileSizeToBigintInVideos < ActiveRecord::Migration
  def change
    change_column :videos, :video_file_size, :integer, limit: 8
  end
end
