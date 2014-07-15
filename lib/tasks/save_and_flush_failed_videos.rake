desc 'Save and flush failed videos from Downloads'
task :import_videos => :environment do
  [ 'failed' ].each do |failed_file_type|
    Dir.glob(
      "#{ENV['HOME']}/Downloads/**/*.#{failed_file_type}"
    ).map do |failed_file_marker_path|
      failed_file_marker_path.gsub(/\.#{failed_file_type}$/, '')
    end.each do |failed_file_path|
      if File.exist?(failed_file_path)
        puts failed_file_path
        FailedVideo.from_file(failed_file_path)
        FileUtils.rm_f(failed_file_path)
      end
    end
  end
end
