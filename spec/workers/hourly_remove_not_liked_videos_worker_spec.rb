require 'spec_helper'

describe HourlyRemoveNotLikedVideosWorker do

  let(:id) { double('id') }

  describe 'flush not liked videos' do
    after { subject.perform }

    it { Video.should_receive(:flush_not_liked!) }
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
