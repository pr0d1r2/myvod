class CreateBadWords < ActiveRecord::Migration
  def change
    create_table :bad_words do |t|
      t.string :word, :null => false
      t.timestamps
    end
    add_index :bad_words, :word, :unique => true
  end
end
