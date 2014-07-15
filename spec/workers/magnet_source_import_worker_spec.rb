require 'spec_helper'

describe MagnetSourceImportWorker do

  let(:magnet_source_id) { 8472 }
  let(:magnet_source) { FactoryGirl.create(:magnet_source) }

  it { should be_processed_in :magnet_source_import }
  it { should be_retryable true }
  it { should be_unique }

  it 'run magnet_source download' do
    MagnetSource.should_receive(:import!).with(magnet_source_id).and_return(
      true
    )
    subject.perform(magnet_source_id)
  end

  it 'should expire requests after 1 minute' do
    expect do
      Timeout.should_receive(:timeout).with(1.minute.to_i).and_raise(
        Timeout::Error
      )
      subject.perform(magnet_source.id)
    end.to raise_error(Timeout::Error)
  end

end
