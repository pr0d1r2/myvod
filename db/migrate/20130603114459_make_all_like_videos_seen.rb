class MakeAllLikeVideosSeen < ActiveRecord::Migration

  def up
    Video.like.find_in_batches(batch_size: 10) do |videos|
      videos.each do |video|
        video.update_attribute(:seen, true)
      end
    end
  end

  def down
    Video.like.find_in_batches(batch_size: 10) do |videos|
      videos.each do |video|
        video.update_attribute(:seen, nil)
      end
    end
  end

end
