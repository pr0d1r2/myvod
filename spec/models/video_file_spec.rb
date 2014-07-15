require 'spec_helper'

describe VideoFile do

  let(:path) { "#{input_files_directory}/myvod-example.m4v" }
  before do
    FileUtils.cp(Rails.root.join('db/seeds/videos/one_second.m4v'), path)
  end
  before do
    %w(done failed stderr).each do |type|
      FileUtils.rm("#{path}.#{type}") if File.exist?("#{path}.#{type}")
    end
  end

  let(:the_object) { VideoFile.new(path) }
  subject { the_object }

  describe '.import' do
    let(:video_file) do
      double('video_file', :import => true, :parent_object= => true)
    end
    before { VideoFile.stub(new: video_file) }
    after { VideoFile.import(path) }

    it 'should create instance with givem param' do
      VideoFile.should_receive(:new).with(path).and_return(video_file)
    end

    it 'should call import on new instance' do
      video_file.should_receive(:import)
    end

    it 'should set parent object' do
      video_file.should_receive(:parent_object=).with(nil)
    end
  end

  describe '#import' do
    let(:done) { false }
    before { subject.stub(processed?: processed, done?: done) }
    after { subject.import }

    context 'when already processed' do
      let(:processed) { true }

      it { subject.import.should be_nil }

      context 'and done' do
        let(:done) { true }

        it { subject.should_receive(:remove!) }
      end
    end

    context 'when not processed before' do
      let(:processed) { false }

      it { subject.should_receive(:process) }
    end
  end

  describe '#processed?' do
    let(:done) { false }
    let(:failed) { false }
    let(:failed_due_to_error) { false }
    before do
      subject.stub(
        done?: done,
        failed?: failed,
        failed_due_to_error?: failed_due_to_error
      )
    end

    its(:processed?) { should be_false }

    context 'when done' do
      let(:done) { true }

      its(:processed?) { should be_true }
    end

    context 'when failed' do
      let(:failed) { true }

      its(:processed?) { should be_true }
    end

    context 'when failed due to error' do
      let(:failed_due_to_error) { true }

      its(:processed?) { should be_true }
    end
  end

  let(:return_value) { double('return_value') }

  describe '#done?' do
    before do
      File.should_receive(:exist?).with(
        "#{path}.done"
      ).and_return(return_value)
    end

    its(:done?) { should == return_value }
  end

  describe '#failed?' do
    before do
      File.should_receive(:exist?).with(
        "#{path}.failed"
      ).and_return(return_value)
    end

    its(:failed?) { should == return_value }
  end

  describe '#failed_due_to_error?' do
    before do
      File.should_receive(:exist?).with(
        "#{path}.failed_due_to_error"
      ).and_return(return_value)
    end

    its(:failed_due_to_error?) { should == return_value }
  end

  describe '#remove!' do
    before do
      FileUtils.should_receive(:rm).with(path).and_return(return_value)
    end

    its(:remove!) { should == return_value }
  end

  describe '#process' do
    describe 'when everything is ok' do
      before { Video.destroy_all }
      after { FileUtils.rm(path) if File.symlink?(path) }

      it 'should process it' do
        expect do
          subject.send(:process).should be_true
        end.to change(Video, :count).by(1)
        File.symlink?(path).should be_true
        File.exist?("#{path}.done").should be_true
        File.exist?("#{path}.stderr").should be_true
      end
    end

    describe 'when error occured on video record creation' do
      after do
        if File.exist?("#{path}.failed_due_to_error")
          FileUtils.rm("#{path}.failed_due_to_error")
        end
      end

      it 'should mark it as failed_due_to_error' do
        expect do
          Video.should_receive(:create_from_file).with(path, nil).and_raise(
            StandardError
          )
          subject.send(:process).should be_false
        end.not_to change(Video, :count)
        File.symlink?(path).should be_false
        File.exist?("#{path}.done").should be_false
        File.exist?("#{path}.failed_due_to_error").should be_true
        File.exist?("#{path}.stderr").should be_false
      end
    end

    describe 'when video record creation failed' do
      let(:not_importable) { false }
      let(:video) do
        double('video', valid?: false, not_importable?: not_importable)
      end

      it 'should mark it as failed' do
        expect do
          Video.should_receive(:create_from_file).with(path, nil).and_return(
            video
          )
          subject.send(:process).should be_false
        end.not_to change(Video, :count)
        File.symlink?(path).should be_false
        File.exist?("#{path}.done").should be_false
        File.exist?("#{path}.failed").should be_true
        File.exist?("#{path}.stderr").should be_true
      end

      context 'when video is not_importable' do
        let(:not_importable) { true }

        it 'should mark it as failed' do
          expect do
            Video.should_receive(:create_from_file).with(path, nil).and_return(
              video
            )
            subject.send(:process).should be_true
          end.not_to change(Video, :count)
          File.exist?(path).should be_false
          File.exist?("#{path}.done").should be_true
          File.exist?("#{path}.failed").should be_false
          File.exist?("#{path}.stderr").should be_true
        end
      end
    end
  end

  describe '#done!' do
    before do
      FileUtils.should_receive(:touch).with(
        "#{path}.done"
      ).and_return(return_value)
    end

    its(:done!) { should == return_value }
  end

  describe '#failed!' do
    let(:return_value) { true }
    before do
      FileUtils.should_receive(:touch).with(
        "#{path}.failed"
      ).and_return(return_value)
      FailedVideo.should_receive(:from_file).with(path)
      subject.should_receive(:remove!)
    end

    its(:failed!) { should be_false }

    context 'when failed to touch file' do
      let(:return_value) { false }

      it 'should raise error' do
        expect do
          subject.send(:failed!)
        end.to raise_error(VideoFile::CannotTouchFailedFile)
      end
    end
  end

  describe '#failed_due_to_error!' do
    let(:return_value) { true }
    before do
      FileUtils.should_receive(:touch).with(
        "#{path}.failed_due_to_error"
      ).and_return(return_value)
    end

    its(:failed_due_to_error!) { should be_false }

    context 'when failed to touch file' do
      let(:return_value) { false }

      it 'should raise error' do
        expect do
          subject.send(:failed_due_to_error!)
        end.to raise_error(VideoFile::CannotTouchFailedDueToErrorFile)
      end
    end
  end

  describe '#capture_stderr'  do
    subject do
      the_object.send(:capture_stderr) do
        $stderr.puts 'example stderr'
      end
    end

    it { should == "example stderr\n" }
  end

  its(:done_file_path) { should == "#{path}.done" }

  its(:failed_file_path) { should == "#{path}.failed" }

  its(:failed_due_to_error_file_path) do
    should == "#{path}.failed_due_to_error"
  end

  context 'when importing existing video' do
    let!(:existing_video) { FactoryGirl.create(:video_one_second) }
    after { existing_video.destroy! }

    it 'should not import video and remove source video' do
      expect do
        VideoFile.import(path)
      end.not_to change(Video, :count)
      File.exist?(path).should be_false
    end
  end

  context 'when importing sample video' do
    let(:path) { "#{input_files_directory}/myvod-example-sample.m4v" }
    before do
      FileUtils.cp(Rails.root.join('db/seeds/videos/one_second.m4v'), path)
    end

    it 'should not import video and remove source video' do
      expect do
        VideoFile.import(path)
      end.not_to change(Video, :count)
      File.exist?(path).should be_false
    end
  end

end
