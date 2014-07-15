# sidetiq worker that do daily magnet sources import
class DailyMagnetSourcesImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :daily_magnet_sources_import

  recurrence backfill: true do
    daily
  end

  TIMEOUT = 1.minute.to_i

  def perform
    Timeout.timeout(TIMEOUT) do
      MagnetSource.pluck(:id).map do |id|
        MagnetSourceImportWorker.perform_async(id)
      end
    end
  end
end
