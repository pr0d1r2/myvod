# worker that do magnet source import
class MagnetSourceImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :magnet_source_import, unique: true, retry: true

  TIMEOUT = 1.minute.to_i

  def perform(magnet_source_id)
    Timeout.timeout(TIMEOUT) do
      MagnetSource.import!(magnet_source_id)
    end
  end
end
