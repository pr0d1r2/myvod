class AddDurationToVideos < ActiveRecord::Migration

  def change
    change_table :videos do |t|
      t.string :duration, :null => false
    end
  end

end
