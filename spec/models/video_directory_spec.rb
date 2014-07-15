require 'spec_helper'

describe VideoDirectory do

  let(:file) { 'myvod-example.m4v' }
  let(:file_path) { "#{path}/#{file}" }
  let(:path) { input_directories_directory }
  before do
    Dir.mkdir(path) unless File.directory?(path)
    unless File.exist?(file_path)
      FileUtils.cp(
        Rails.root.join('db/seeds/videos/one_second.m4v'), file_path
      )
    end
  end
  after { FileUtils.rm_rf(path) if File.directory?(path) }
  subject { VideoDirectory.new(path) }

  describe '.import' do
    let(:video_directory) do
      double('video_directory', :import => true, :parent_object= => true)
    end
    before { VideoDirectory.stub(new: video_directory) }
    after { VideoDirectory.import(path) }

    it 'should create instance with givem param' do
      VideoDirectory.should_receive(:new).with(path).and_return(
        video_directory
      )
    end

    it 'should call import on new instance' do
      video_directory.should_receive(:import)
    end

    it 'should set parent object' do
      video_directory.should_receive(:parent_object=).with(nil)
    end
  end

  describe 'import' do
    before { Video.destroy_all }
    after do
      FileUtils.rm("#{file_path}.done") if File.exist?("#{file_path}.done")
    end
    before { subject.parent_object = nil }

    it 'should import it' do
      expect do
        subject.send(:import)
      end.to change(Video, :count).by(1)
      File.symlink?(file_path).should be_true
      File.exist?("#{file_path}.done").should be_true
    end

    context 'when directory contains dead links' do
      before do
        system("cd #{path} && ln -s bad_source.avi bad_source_link.avi")
      end
      after { system("cd #{path} && rm -f bad_source_link.avi") }

      it 'should import it' do
        expect do
          subject.send(:import)
        end.to change(Video, :count).by(1)
      end
    end
  end

  its(:convertable_file_types) do
    should == %w(
      avi AVI
      mp4 MP4
      m4v M4V
      wmv WMV
      mov MOV
      flv FLV
      mpg MPG
      mpeg MPEG
      rm RM
      rmvb RMVB
    )
  end

end
