desc 'Import all videos from Downloads'
task :import_videos => :environment do
  Dir.glob("#{ENV['HOME']}/Downloads/*").each do |directory|
    magnet_id = File.basename(directory).to_i
    VideoDirectoryImportWorker.perform_async(directory, 'Magnet', magnet_id)
  end
end
