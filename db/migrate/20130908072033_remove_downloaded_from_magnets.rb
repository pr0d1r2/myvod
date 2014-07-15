class RemoveDownloadedFromMagnets < ActiveRecord::Migration
  def change
    remove_column :magnets, :downloaded
  end
end
