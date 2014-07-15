# sidetiq worker that do hourly magnet download enqueue
class HourlyMagnetDownloadEnqueueWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :hourly_magnet_download_enqueue

  recurrence backfill: true do
    hourly
  end

  TIMEOUT = 1.minute.to_i

  def perform
    Timeout.timeout(TIMEOUT) do
      if Sidekiq::Stats.new.queues['magnet_download'] == 0 &&
         Sidekiq::Stats.new.queues['video_directory_import'] < 10
        Magnet.enqueue_download!
      end
    end
  end
end
