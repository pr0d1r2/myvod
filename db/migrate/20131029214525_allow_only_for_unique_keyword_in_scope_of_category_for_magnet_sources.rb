class AllowOnlyForUniqueKeywordInScopeOfCategoryForMagnetSources < ActiveRecord::Migration
  def change
    add_index :magnet_sources, [:keyword, :category], :unique => true
  end
end
