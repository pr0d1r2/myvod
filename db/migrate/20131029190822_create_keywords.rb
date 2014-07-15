class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :keyword, :null => false
      t.string :categories, :null => false
      t.timestamps
    end
  end
end
