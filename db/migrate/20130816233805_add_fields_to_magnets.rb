class AddFieldsToMagnets < ActiveRecord::Migration
  def change
    change_table :magnets do |t|
      t.string :title, :null => false
      t.integer :seeders, :null => false
      t.integer :leechers, :null => false
      t.string :category, :null => false
      t.integer :torrent_id, :null => false
      t.string :url, :null => false
    end
  end
end
