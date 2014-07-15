class AddDefaultValueToFlagsInMagnets < ActiveRecord::Migration
  def change
    Magnet.connection.update('UPDATE magnets SET flags = 0 WHERE flags IS NULL')
    change_column :magnets, :flags, :integer, :null => false, :default => 0
  end
end
