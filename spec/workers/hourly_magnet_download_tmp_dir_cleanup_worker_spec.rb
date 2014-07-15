require 'spec_helper'

describe HourlyMagnetDownloadTmpDirCleanupWorker do
  context 'when runned successfully' do
    after { subject.perform }

    it { MagnetTmpDir.should_receive(:cleanup!) }
  end

  it 'should expire requests after 59 minutes' do
    expect do
      Timeout.should_receive(:timeout).with(59.minutes.to_i).and_raise(
        Timeout::Error
      )
      subject.perform
    end.to raise_error(Timeout::Error)
  end
end
