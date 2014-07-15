require 'spec_helper'

describe ApplicationHelper do

  subject { helper }

  its(:navigation_options) do
    should == {
      'first unseen' => { short_name: 'n', path: '/unseens/1' },
      'unseens' => { short_name: 'u', path: '/unseens' },
      'videos' => { short_name: 'v', path: '/videos' },
      'likes' => { short_name: 'l', path: '/likes' },
      'bests' => { short_name: 'b', path: '/bests' },
      'magnets' => { short_name: 'm', path: '/magnets' },
      'random(best)' => { short_name: 'rb', path: '/random_bests/1' },
      'random(like)' => { short_name: 'rl', path: '/random_likes/1' },
      'sidekiq' => { short_name: 's', path: '/sidekiq' }
    }
  end

  its(:short_navigation_options) do
    should == {
      'n' => '/unseens/1',
      'u' => '/unseens',
      'v' => '/videos',
      'l' => '/likes',
      'b' => '/bests',
      'm' => '/magnets',
      'rb' => '/random_bests/1',
      'rl' => '/random_likes/1',
      's' => '/sidekiq'
    }
  end

  its(:long_navigation_options) do
    should == {
      'first unseen' => '/unseens/1',
      'unseens' => '/unseens',
      'videos' => '/videos',
      'likes' => '/likes',
      'bests' => '/bests',
      'magnets' => '/magnets',
      'random(best)' => '/random_bests/1',
      'random(like)' => '/random_likes/1',
      'sidekiq' => '/sidekiq'
    }
  end

  describe '#menuitem' do
    subject { helper.menuitem('name', '/path') }

    it { should == '<li> <a href="/path">name</a> </li>' }

    context 'when path is current path' do
      let(:request) { double(fullpath: '/path') }
      before { helper.stub(request: request) }

      it { should == '<li class="active"> <a href="/path">name</a> </li>' }
    end
  end

  describe '#menuitem_li' do
    subject { helper.menuitem_li('/path') }

    it { should == '<li>' }

    context 'when path is current path' do
      let(:request) { double(fullpath: '/path') }
      before { helper.stub(request: request) }

      it { should == '<li class="active">' }
    end
  end

end
