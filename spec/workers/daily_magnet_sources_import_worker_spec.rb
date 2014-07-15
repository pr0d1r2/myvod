require 'spec_helper'

describe DailyMagnetSourcesImportWorker do

  let(:id) { double('id') }

  before do
    MagnetSource.stub(pluck: [id])
    MagnetSourceImportWorker.stub(:perform_async)
  end

  describe 'run magnet sources import' do
    after { subject.perform }

    it { MagnetSource.should_receive(:pluck).with(:id).and_return([id]) }

    it { MagnetSourceImportWorker.should_receive(:perform_async).with(id) }
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
