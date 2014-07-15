class AddKeywordIdToMagnetSources < ActiveRecord::Migration
  def change
    change_table :magnet_sources do |t|
      t.belongs_to :keyword
    end
  end
end
