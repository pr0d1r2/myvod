class AddUniqueIndexOnTorrentIdInMagnets < ActiveRecord::Migration
  def change
    add_index :magnets, :torrent_id, :unique => true
  end
end
