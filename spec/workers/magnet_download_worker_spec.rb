require 'spec_helper'

describe MagnetDownloadWorker do

  let(:timeout) { Rails.configuration.magnet_download_timeout }
  let(:magnet_id) { 8472 }
  let(:magnet) { FactoryGirl.create(:magnet) }

  it { should be_processed_in :magnet_download }
  it { should be_retryable false }
  it { should be_unique }

  it 'run magnet download' do
    Magnet.should_receive(:download!).with(magnet_id).and_return(true)
    subject.perform(magnet_id)
  end

  it 'should expire requests after expiration period gone' do
    expect do
      Timeout.should_receive(:timeout).with(timeout).and_raise(
        Timeout::Error
      )
      subject.perform(magnet.id)
    end.to raise_error(Timeout::Error)
    magnet.reload.should be_download_timeouted
  end

  context 'when error occured' do
    let(:error) { StandardError }
    before do
      Magnet.should_receive(:download!).with(magnet.id).and_raise(error)
    end

    it 'should mark magnet as download timeouted' do
      expect do
        subject.perform(magnet.id)
      end.to raise_error(error)
      magnet.reload.should be_download_errored
    end
  end

end
