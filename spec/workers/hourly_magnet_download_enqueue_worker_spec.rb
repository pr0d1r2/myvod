require 'spec_helper'

describe HourlyMagnetDownloadEnqueueWorker do

  let(:magnet_download_queue_size) { 0 }
  let(:video_directory_import_queue_size) { 9 }
  before do
    Sidekiq::Stats.any_instance.stub(queues: {
      'magnet_download' => magnet_download_queue_size,
      'video_directory_import' => video_directory_import_queue_size
    })
  end

  context 'when magnet_download queue empty' do
    let(:magnet_download_queue_size) { 0 }
    after { subject.perform }

    it { Magnet.should_receive(:enqueue_download!) }

    context 'but video_directory_import queue have 10 jobs' do
      let(:video_directory_import_queue_size) { 10 }

      it { Magnet.should_not_receive(:enqueue_download!) }
    end
  end

  context 'when magnet_download queue not empty' do
    let(:magnet_download_queue_size) { 1 }
    after { subject.perform }

    it { Magnet.should_not_receive(:enqueue_download!) }
  end

  it 'should expire requests after 1 minute' do
    expect do
      Timeout.should_receive(:timeout).with(1.minute.to_i).and_raise(
        Timeout::Error
      )
      subject.perform
    end.to raise_error(Timeout::Error)
  end

end
