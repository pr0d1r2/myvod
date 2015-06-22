require 'fileutils'

# helpers to handle filesystem operation in tests
module FilesystemSpecHelpers
  def cleanup_download_directories
    if File.exist?(Rails.configuration.magnet_download_tmp_dir)
      FileUtils.rm_rf(Rails.configuration.magnet_download_tmp_dir)
    end
    if File.exist?(Rails.configuration.magnet_download_finished_dir)
      FileUtils.rm_rf(Rails.configuration.magnet_download_finished_dir)
    end
  end

  def create_download_directories
    unless File.directory?(Rails.configuration.magnet_download_tmp_dir)
      FileUtils.mkdir_p(Rails.configuration.magnet_download_tmp_dir)
    end
    unless File.directory?(Rails.configuration.magnet_download_finished_dir)
      FileUtils.mkdir_p(Rails.configuration.magnet_download_finished_dir)
    end
  end

  def input_files_directory
    "#{Rails.root}/tmp/test/input_files"
  end

  def prepare_input_files_directory
    unless File.directory?(input_files_directory)
      FileUtils.mkdir_p(input_files_directory)
    end
  end

  def cleanup_input_files_directory
    if File.directory?(input_files_directory)
      FileUtils.rm_rf(input_files_directory)
    end
  end

  def input_directories_directory
    "#{Rails.root}/tmp/test/input_directories"
  end

  def prepare_input_directories_directory
    unless File.directory?(input_directories_directory)
      FileUtils.mkdir_p(input_directories_directory)
    end
  end

  def cleanup_input_directories_directory
    if File.directory?(input_directories_directory)
      FileUtils.rm_rf(input_directories_directory)
    end
  end
end
