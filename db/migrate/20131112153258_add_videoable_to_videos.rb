class AddVideoableToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :videoable_type, :string
    add_column :videos, :videoable_id, :integer
    add_index :videos, [:videoable_id, :videoable_type]
  end
end
