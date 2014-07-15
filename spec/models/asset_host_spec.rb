require 'spec_helper'

describe AssetHost do

  let(:the_object) { AssetHost.new }

  describe '#call' do
    let(:source) { OpenStruct.new(hash: 2_480_209_022_178_632_351) }
    let(:request) { OpenStruct.new(host: 'my-vod.eu') }

    subject { the_object.call(source, request) }

    it { should =~ %r{https:\/\/myvod:myfancypassword@a[0-3]\.my-vod\.eu} }
  end

end
