class AddIndexMagnetSourceIdToMagnets < ActiveRecord::Migration
  def change
    add_index :magnets, :magnet_source_id
  end
end
