# worker that do video directories import
class VideoDirectoryImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :video_directory_import, unique: true, retry: false

  def perform(video_directory_path, parent_type = nil, parent_id = nil)
    if parent_type
      VideoDirectory.import(
        video_directory_path, parent_type.constantize.find(parent_id)
      )
    else
      VideoDirectory.import(video_directory_path)
    end
  end
end
