# class describing magnet tmp directory used for downloads
class MagnetTmpDir
  PATH = Rails.configuration.magnet_download_tmp_dir
  MINIMUM_FREE_DISK_SPACE = Rails.configuration.magnet_download_tmp_dir_free_space # GB # rubocop:disable LineLength
  MINIMUM_EXISTANCE_TIME_FOR_REMOVAL = Rails.configuration.magnet_download_timeout + 1.hour.to_i # rubocop:disable LineLength

  def self.have_disk_space?
    FreeDiskSpace.gigabytes(PATH) > MINIMUM_FREE_DISK_SPACE
  end

  def self.sub_dirs
    Dir.glob("#{PATH}/**")
  end

  def self.cleanup_sub_dirs
    sub_dirs.reject do |dir|
      File.stat(dir).ctime > (Time.now - MINIMUM_EXISTANCE_TIME_FOR_REMOVAL)
    end
  end

  def self.cleanup!
    cleanup_sub_dirs.map { |dir| FileUtils.rm_rf(dir) }
  end
end
