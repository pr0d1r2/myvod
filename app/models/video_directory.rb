# describes video directory containing video files to import
class VideoDirectory < Dir
  attr_writer :parent_object

  def self.import(path, parent_object = nil)
    vd = new(path)
    vd.parent_object = parent_object
    vd.import
  end

  def import
    convertable_file_types.each do |convertable_file_type|
      Dir.glob(
        "#{path}/**/*.#{convertable_file_type}"
      ).each do |convertable_file_path|
        if File.exist?(convertable_file_path)
          VideoFile.import(convertable_file_path, @parent_object)
        end
      end
    end
  end

  private

    def convertable_file_types
      Video::CONVERTABLE_INPUT.map { |f| [f, f.upcase] }.flatten
    end
end
