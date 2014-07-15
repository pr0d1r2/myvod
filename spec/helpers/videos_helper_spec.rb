require 'spec_helper'

describe VideosHelper do

  describe '#show_first_unseen_button' do
    before { helper.stub(unseen_count: 0) }
    subject { helper.show_first_unseen_button }

    it do
      should == '<span> <a class="btn btn-primary" href="/unseens/1">' +
                'show first unseen</a> ( 0 to see ) </span>'
    end
  end

  describe '#unseens_to_see' do
    before { helper.stub(unseen_count: 0) }
    subject { helper.unseens_to_see }

    it { should == '( 0 to see )' }
  end

  describe '#unseen_count' do
    before { Video.should_receive(:unseen_count).and_return(0) }
    subject { helper.unseen_count }

    it { should == 0 }
  end

end
