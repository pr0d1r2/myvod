class AddIndexKeywordIdToMagnetSources < ActiveRecord::Migration
  def change
    add_index :magnet_sources, :keyword_id
  end
end
