class CreateFailedVideos < ActiveRecord::Migration
  def change
    create_table :failed_videos do |t|
      t.string :md5, :limit => 32, :null => false
      t.timestamps
    end
  end
end
