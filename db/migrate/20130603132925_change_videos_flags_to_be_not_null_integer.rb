class ChangeVideosFlagsToBeNotNullInteger < ActiveRecord::Migration

  def up
    Video.connection.execute("UPDATE videos SET flags=0 WHERE flags IS NULL")
    change_column :videos, :flags, :integer, :null => false, :default => 0
  end

  def down
    change_column :videos, :flags, :integer
    Video.connection.execute("UPDATE videos SET flags=NULL WHERE flags=0")
  end

end
