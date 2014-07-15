class RenameKeywordToMagnetKeywordInMagnetSources < ActiveRecord::Migration
  def change
    rename_column :magnet_sources, :keyword, :magnet_keyword
  end
end
