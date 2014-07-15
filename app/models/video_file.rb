require 'fileutils'
require 'tempfile'

# describes video file used by video directory
class VideoFile < File
  attr_writer :parent_object

  class CannotTouchFailedFile < StandardError; end
  class CannotTouchFailedDueToErrorFile < StandardError; end

  def self.import(path, parent_object = nil)
    vf = new(path)
    vf.parent_object = parent_object
    vf.import
  end

  def import
    if processed?
      remove! if done?
    else
      process
    end
  end

  private

    def processed?
      done? || failed? || failed_due_to_error?
    end

    def done?
      File.exist?(done_file_path)
    end

    def failed?
      File.exist?(failed_file_path)
    end

    def failed_due_to_error?
      File.exist?(failed_due_to_error_file_path)
    end

    def remove!
      FileUtils.rm(path)
    end

    def link_original_to_source!
      FileUtils.ln_s(@video.video.path, path)
    end

    def process
      retval = true
      stderr = capture_stderr { retval = process_core }
      File.open("#{path}.stderr", 'w') { |file| file.write(stderr) }
      retval
    rescue
      failed_due_to_error!
    end

    def process_core # rubocop:disable LineLength
      @video = Video.create_from_file(path, @parent_object)
      if @video.valid?
        processed!
        link_original_to_source!
        true
      else
        processed! and return true if @video.not_importable? # rubocop:disable AndOr
        failed!
      end
    end

    def processed!
      done!
      remove!
    end

    def done!
      FileUtils.touch(done_file_path)
    end

    def failed!
      FailedVideo.from_file(path)
      remove!
      FileUtils.touch(failed_file_path) || fail(CannotTouchFailedFile)
      false
    end

    def failed_due_to_error!
      FileUtils.touch(failed_due_to_error_file_path) ||
        fail(CannotTouchFailedDueToErrorFile)
      false
    end

    def capture_stderr
      stderr = $stderr.dup
      Tempfile.open 'stderr-redirect' do |temp|
        $stderr.reopen temp.path, 'w+'
        yield if block_given?
        $stderr.reopen stderr
        temp.read
      end
    end

    def done_file_path
      "#{path}.done"
    end

    def failed_file_path
      "#{path}.failed"
    end

    def failed_due_to_error_file_path
      "#{path}.failed_due_to_error"
    end
end
