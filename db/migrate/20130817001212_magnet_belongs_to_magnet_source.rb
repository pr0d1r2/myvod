class MagnetBelongsToMagnetSource < ActiveRecord::Migration
  def change
    change_table :magnets do |t|
      t.belongs_to :magnet_source, :null => false
    end
  end
end
