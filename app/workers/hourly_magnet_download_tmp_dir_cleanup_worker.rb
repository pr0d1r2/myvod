# sidetiq worker that do hourly magnet download tmp dir cleanup
class HourlyMagnetDownloadTmpDirCleanupWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :hourly_magnet_download_tmp_dir_cleanup

  recurrence backfill: true do
    hourly
  end

  TIMEOUT = 59.minutes.to_i

  def perform
    Timeout.timeout(TIMEOUT) do
      MagnetTmpDir.cleanup!
    end
  end
end
