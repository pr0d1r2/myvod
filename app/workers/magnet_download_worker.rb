# worker that do magnet download
class MagnetDownloadWorker
  include Sidekiq::Worker

  sidekiq_options queue: :magnet_download, unique: true, retry: false

  TIMEOUT = Rails.configuration.magnet_download_timeout

  def perform(magnet_id)
    Timeout.timeout(TIMEOUT) do
      Magnet.download!(magnet_id)
    end
  rescue Timeout::Error
    Magnet.download_timeout!(magnet_id)
    raise
  rescue
    Magnet.download_error!(magnet_id)
    fail
  end
end
