# sidetiq worker that do hourly remove of not liked videos
class HourlyRemoveNotLikedVideosWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :hourly_remove_not_liked_videos

  recurrence backfill: true do
    hourly
  end

  TIMEOUT = 59.minutes.to_i

  def perform
    Timeout.timeout(TIMEOUT) do
      Video.flush_not_liked!
    end
  end
end
