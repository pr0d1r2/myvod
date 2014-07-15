class MigrateDownloadedMagnetsToWorkflow < ActiveRecord::Migration
  def change
    Magnet.where("(magnets.flags in (4,5,6,7))").find_in_batches do |magnets|
      magnets.each do |magnet|
        magnet.downloaded!
        magnet.update_attribute(:flags, (magnet.flags-4))
      end
    end
  end
end
