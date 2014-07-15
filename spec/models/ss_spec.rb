require 'spec_helper'

describe SS do
  let(:seconds) { 120 }
  let(:ss) { SS.new(seconds) }

  describe '#ss' do
    subject { ss.ss }

    it { should == '00:02:00' }

    context 'when seconds is 70.0' do
      let(:seconds) { 70.0 }

      it { should == '00:01:10' }
    end

    context 'when seconds is 7000.0' do
      let(:seconds) { 7000.0 }

      it { should == '01:56:40' }
    end
  end

  describe '#at_percentage' do
    subject { ss.at_percentage(percentage) }

    describe 'when percentage is' do
      context '1%' do
        let(:percentage) { 1 }

        it { should == '00:00:01' }
      end

      context '10%' do
        let(:percentage) { 10 }

        it { should == '00:00:12' }
      end

      context '50%' do
        let(:percentage) { 50 }

        it { should == '00:01:00' }
      end

      context '66%' do
        let(:percentage) { 66 }

        it { should == '00:01:19' }
      end

      context '89%' do
        let(:percentage) { 89 }

        it { should == '00:01:46' }
      end

      context '0.8333333333333334% (100.0/120)' do
        let(:percentage) { 0.8333333333333334 }

        it { should == '00:00:01' }

        context 'and duration is 7200s (2h)' do
          let(:seconds) { 7200 }

          it { should == '00:01:00' }
        end
      end

      context '4.166666666666667% (100.0/24)' do
        let(:percentage) { 4.166666666666667 }

        it { should == '00:00:05' }

        context 'and duration is 7200s (2h)' do
          let(:seconds) { 7200 }

          it { should == '00:05:00' }
        end
      end
    end
  end
end
