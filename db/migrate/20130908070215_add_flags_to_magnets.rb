class AddFlagsToMagnets < ActiveRecord::Migration
  def change
    change_table :magnets do |t|
      t.integer :flags
    end
  end
end
