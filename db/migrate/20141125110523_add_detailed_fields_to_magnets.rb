class AddDetailedFieldsToMagnets < ActiveRecord::Migration
  def change
    change_table :magnets do |t|
      t.integer :files
      t.integer :size, :limit => 8 # size in bytes
      t.datetime :uploaded
      t.text :description
    end
  end
end
