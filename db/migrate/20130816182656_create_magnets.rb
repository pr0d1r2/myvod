class CreateMagnets < ActiveRecord::Migration
  def change
    create_table :magnets do |t|
      t.text :link, :null => false, :unique => true
      t.boolean :downloaded
      t.timestamps
    end
  end
end
