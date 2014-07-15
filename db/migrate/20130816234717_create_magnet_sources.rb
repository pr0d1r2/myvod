class CreateMagnetSources < ActiveRecord::Migration
  def change
    create_table :magnet_sources do |t|
      t.string :keyword, :null => false
      t.integer :category, :null => false
      t.integer :sort_by, :null => false, :default => 7 # ThePirateBay::SortBy::Seeders
      t.integer :number_of_pages, :null => false, :default => 10
      t.timestamps
    end
  end
end
