require 'spec_helper'

describe VideoDirectoryImportWorker do

  let(:path) { "#{input_files_directory}/myvod-example.m4v" }

  it { should be_processed_in :video_directory_import }
  it { should be_retryable false }
  it { should be_unique }

  it 'run video directory import' do
    VideoDirectory.should_receive(:import).with(path)
    subject.perform(path)
  end

  context 'when parent object given' do
    let(:magnet) { FactoryGirl.create(:magnet) }

    it 'run video directory import' do
      VideoDirectory.should_receive(:import).with(path, magnet)
      subject.perform(path, magnet.class.name, magnet.id)
    end
  end

end
