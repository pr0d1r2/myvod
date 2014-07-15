class AddFlagsToVideos < ActiveRecord::Migration

  def change
    change_table :videos do |t|
      t.integer :flags
    end
  end

end
