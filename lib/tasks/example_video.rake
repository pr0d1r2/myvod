desc 'Add one example video from Downloads'
task :example_video => :environment do
  Video::CONVERTABLE_INPUT.each do |filetype|
    Dir.glob("#{ENV['HOME']}/Downloads/**/*.#{filetype}").each do |file|
      puts "#{file}"
      video = Video.create_from_file!(file)
      return true
    end
  end
end
