class CreateVideos < ActiveRecord::Migration

  def change
    create_table :videos do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end

end
