require 'spec_helper'

describe TorrentDetails do
  let(:torrent_id) { 6_232_477 }
  subject { described_class.new(torrent_id) }
  around { |example| VCR.use_cassette('torrent_details') { example.run } }

  its(:files) { should == 3 }

  its(:size) { should == 890_732_416 }

  its(:uploaded) { should == DateTime.new(2011, 3, 10, 10, 44, 47) }

  its(:description) { should include('Sam Flynn') }
end
