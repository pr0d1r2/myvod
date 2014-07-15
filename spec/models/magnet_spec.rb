require 'spec_helper'

describe Magnet do

  let(:magnet_source) { FactoryGirl.create(:magnet_source) }
  let(:magnet) { FactoryGirl.create(:magnet) }
  subject { magnet }
  let(:link) { subject.link }

  its(:seeders?) { should be_true }

  its(:no_seeders?) { should be_false }

  its(:low_total_seeders?) { should be_false }

  its(:has_bad_words?) { should be_false }

  describe '.create_or_update_by_torrent_id' do
    let(:update_attributes) do
      {
        title: 'title updated',
        seeders: 48,
        leechers: 24,
        magnet_link: 'magnet:?xt=urn:btih:updated',
        torrent_id: torrent_id,
        category: 'Audio',
        url: "/torrent/#{torrent_id}/example"
      }
    end
    subject { Magnet.find_by_torrent_id(torrent_id).reload }

    context 'when record with torrent_id exist' do
      let(:torrent_id) { magnet.torrent_id }
      before do
        magnet_source.magnets.create_or_update_by_torrent_id(update_attributes)
      end

      its(:title) { should == update_attributes[:title] }
      its(:seeders) { should == update_attributes[:seeders] }
      its(:leechers) { should == update_attributes[:leechers] }
      its(:magnet_link) { should == update_attributes[:magnet_link] }
      its(:category) { should == update_attributes[:category] }
      its(:url) { should == update_attributes[:url] }
    end

    context 'when record with torrent_id does not exist' do
      let(:torrent_id) { 4 }
      let(:magnet_source) { FactoryGirl.create(:magnet_source) }
      before do
        magnet_source.magnets.create_or_update_by_torrent_id(
          update_attributes.merge(magnet_source: magnet_source)
        )
      end

      its(:title) { should == update_attributes[:title] }
      its(:seeders) { should == update_attributes[:seeders] }
      its(:leechers) { should == update_attributes[:leechers] }
      its(:magnet_link) { should == update_attributes[:magnet_link] }
      its(:category) { should == update_attributes[:category] }
      its(:url) { should == update_attributes[:url] }
    end

    context 'when trying to import with non-numeric torrent_id' do
      let(:torrent_id) { 'non-numeric' }

      it do
        expect do
          magnet_source.magnets.create_or_update_by_torrent_id(
            update_attributes
          )
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#magnet_link' do
    its(:magnet_link) { should == subject.link }
  end

  describe '#magnet_link=' do
    let(:changed_magnet_link) { 'magnet:?xt=urn:btih:changed' }
    before { subject.magnet_link = changed_magnet_link }

    its(:link) { should == changed_magnet_link }
  end

  describe '#download!' do
    let(:download_tmp_directory) { '/tmp' }
    before do
      BitTorrent.stub(download!: true)
      subject.stub(:create_download_tmp_directory!)
      subject.stub(:move_to_finished_download_directory!)
      subject.stub(download_tmp_directory: download_tmp_directory)
      VideoDirectoryImportWorker.stub(:perform_async)
    end

    context 'when download failed' do
      before do
        BitTorrent.should_receive(:download!).with(
          link, Magnet::BITTORRENT_OPTIONS.merge(
            destination_directory: download_tmp_directory
          )
        ).and_raise(BitTorrent::DownloadError)
      end

      it 'should raise error and not mark as downloaded' do
        expect do
          subject.download!
        end.to raise_error(BitTorrent::DownloadError)
        subject.downloaded?.should be_false
      end
    end

    context 'when download succeded' do
      before { subject.download! }

      its(:downloaded?) { should be_true }

      its(:seen) { should be_true }

      its(:like) { should be_true }
    end

    describe 'behavior' do
      after { subject.download! }

      it { subject.should_receive :create_download_tmp_directory! }

      it 'should download bit torrent' do
        BitTorrent.should_receive(:download!).with(
          link, Magnet::BITTORRENT_OPTIONS.merge(
            destination_directory: download_tmp_directory
          )
        ).and_return(true)
      end

      it { subject.should_receive :move_to_finished_download_directory! }

      it do
        VideoDirectoryImportWorker.should_receive(:perform_async).with(
          subject.send(:download_finished_directory),
          subject.class.name,
          subject.id
        )
      end
    end

    describe 'download failures' do
      let(:extra_params) { nil }
      subject do
        if extra_params
          FactoryGirl.create(magnet, extra_params)
        else
          FactoryGirl.create(magnet)
        end
      end
      shared_context 'should raise error and not perform download action' do
        it 'should raise error and not perform download action' do
          expect { subject.download! }.to raise_error(expected_error)
          subject.should_not_receive(:create_download_tmp_directory!)
          BitTorrent.should_not_receive(:download!)
          subject.should_not_receive(:move_to_finished_download_directory!)
          subject.should_not_receive(:update_attributes)
        end
      end

      context 'when already downloaded before' do
        let(:magnet) { :magnet_downloaded }
        let(:expected_error) { Magnet::AlreadyDownloadedError }

        include_context 'should raise error and not perform download action'
      end

      context 'when download errored before' do
        let(:magnet) { :magnet_with_download_error }
        let(:expected_error) { Magnet::DownloadErrorPreviouslyError }

        include_context 'should raise error and not perform download action'
      end

      context 'when download timeouted before' do
        let(:magnet) { :magnet_with_download_timeout }
        let(:expected_error) { Magnet::DownloadTimeoutPreviouslyError }

        include_context 'should raise error and not perform download action'
      end

      context 'when magnet has no seeders' do
        let(:magnet) { :magnet_without_seeders }
        let(:expected_error) { Magnet::NoSeedersError }

        include_context 'should raise error and not perform download action'
      end

      context 'when magnet has low total seeders' do
        let(:magnet) { :magnet_with_low_total_seeders }
        let(:expected_error) { Magnet::LowTotalSeedersError }

        include_context 'should raise error and not perform download action'
      end

      context 'when magnet title contain bad words' do
        let(:bad_word) { FactoryGirl.create(:bad_word) }
        let(:magnet) { :magnet }
        let(:extra_params) do
          { title: "example title with #{bad_word.word}" }
        end
        let(:expected_error) { Magnet::HasBadWordsError }

        include_context 'should raise error and not perform download action'
      end
    end
  end

  describe '#create_download_tmp_directory!' do
    let(:download_dir) { '/tmp/1' }
    before do
      subject.stub(download_tmp_directory: download_dir)
      FileUtils.stub!(mkdir_p: true)
    end

    context 'when directory created successfully' do
      after { subject.send(:create_download_tmp_directory!) }

      it 'should create directory' do
        FileUtils.should_receive(:mkdir_p).with(download_dir).and_return(true)
      end
    end

    context 'when cannot create directory' do
      before do
        FileUtils.should_receive(:mkdir_p).with(download_dir).and_return(false)
      end

      it 'should create directory' do
        expect do
          subject.send(:create_download_tmp_directory!)
        end.to raise_error(Magnet::DownloadTmpDirectoryError)
      end
    end
  end

  describe '#move_to_finished_download_directory!' do
    let(:download_dir) { '/tmp/1' }
    let(:finished_dir) { '/tmp/finished/1' }
    before do
      subject.stub(
        download_tmp_directory: download_dir,
        download_finished_directory: finished_dir
      )
      FileUtils.stub!(mv: true)
    end

    context 'when directory moved successfully' do
      after { subject.send(:move_to_finished_download_directory!) }

      it 'should create directory' do
        FileUtils.should_receive(:mv).with(
          download_dir, finished_dir
        ).and_return(true)
      end
    end

    context 'when cannot move directory' do
      before do
        FileUtils.should_receive(:mv).with(
          download_dir, finished_dir
        ).and_return(false)
      end

      it 'should create directory' do
        expect do
          subject.send(:move_to_finished_download_directory!)
        end.to raise_error(Magnet::DownloadFinishedDirectoryError)
      end
    end
  end

  describe '#download_tmp_directory' do
    before { subject.stub!(id: 1) }

    its(:download_tmp_directory) do
      should == "#{MagnetTmpDir::PATH}/1"
    end
  end

  describe '#download_finished_directory' do
    before { subject.stub!(id: 1) }

    its(:download_finished_directory) do
      should == "#{Rails.configuration.magnet_download_finished_dir}/1"
    end
  end

  describe 'instance' do
    subject { FactoryGirl.build(:magnet) }

    context 'when magnet with torrent_id already exist in database' do
      let(:existing_magnet) { FactoryGirl.create(:magnet) }
      before { subject.torrent_id = existing_magnet.torrent_id }

      its(:valid?) { should be_false }
    end

    context 'when magnet has non numeric torrent_id' do
      before { subject.torrent_id = 'non-numeric' }

      its(:valid?) { should be_false }
    end
  end

  describe 'value_order scope' do
    let!(:magnet_5_1) { FactoryGirl.create(:magnet, seeders: 5, leechers: 1) }
    let!(:magnet_5_2) { FactoryGirl.create(:magnet, seeders: 5, leechers: 2) }
    let!(:magnet_10_1_seen) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, seen: true)
    end
    let!(:magnet_10_1_like) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, like: true)
    end
    let!(:magnet_10_1_first) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    let!(:magnet_10_3) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 3)
    end
    let!(:magnet_10_1_second) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    subject { described_class.value_order }

    it do
      should == [
        magnet_10_3, magnet_10_1_second, magnet_10_1_first, magnet_10_1_like,
        magnet_10_1_seen,
        magnet_5_2, magnet_5_1,
      ]
    end
  end

  describe 'unseen scope' do
    before { Magnet.destroy_all }
    let!(:magnet1) do
      FactoryGirl.create(:magnet_with_seeders_and_higher_leechers)
    end
    let!(:magnet2) do
      FactoryGirl.create(:magnet_without_seeders)
    end
    let!(:magnet3) do
      FactoryGirl.create(:magnet_with_seeders_and_lower_leechers)
    end
    subject { Magnet.unseen.map(&:id) }

    it { should == [magnet1.id, magnet3.id, magnet2.id] }
  end

  describe 'to_download scope' do
    let!(:magnet_5_1) do
      FactoryGirl.create(:magnet, seeders: 5, leechers: 1)
    end
    let!(:magnet_5_2) do
      FactoryGirl.create(:magnet, seeders: 5, leechers: 2)
    end
    let!(:magnet_10_1_seen) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, seen: true)
    end
    let!(:magnet_10_1_like) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, like: true)
    end
    let!(:magnet_10_1_first) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    let!(:magnet_10_3) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 3)
    end
    let!(:magnet_10_1_second) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    subject { described_class.to_download }

    it do
      should == [
        magnet_10_3, magnet_10_1_second, magnet_10_1_first,
        magnet_5_2, magnet_5_1,
      ]
    end
  end

  describe 'batch_to_download scope' do
    let!(:magnet_5_1) { FactoryGirl.create(:magnet, seeders: 5, leechers: 1) }
    let!(:magnet_5_3) { FactoryGirl.create(:magnet, seeders: 5, leechers: 3) }
    let!(:magnet_5_2) { FactoryGirl.create(:magnet, seeders: 5, leechers: 2) }
    let!(:magnet_5_5) { FactoryGirl.create(:magnet, seeders: 5, leechers: 5) }
    let!(:magnet_5_4) { FactoryGirl.create(:magnet, seeders: 5, leechers: 4) }
    let!(:magnet_10_1_seen) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, seen: true)
    end
    let!(:magnet_10_1_like) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1, like: true)
    end
    let!(:magnet_10_1_first) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    let!(:magnet_10_3) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 3)
    end
    let!(:magnet_10_5) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 5)
    end
    let!(:magnet_10_4) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 4)
    end
    let!(:magnet_10_1_second) do
      FactoryGirl.create(:magnet, seeders: 10, leechers: 1)
    end
    let!(:magnet_1_1) { FactoryGirl.create(:magnet, seeders: 1, leechers: 1) }
    let!(:magnet_3_1) { FactoryGirl.create(:magnet, seeders: 3, leechers: 1) }
    let!(:magnet_3_3) { FactoryGirl.create(:magnet, seeders: 3, leechers: 3) }
    let!(:magnet_3_2) { FactoryGirl.create(:magnet, seeders: 3, leechers: 2) }
    let!(:magnet_3_5) { FactoryGirl.create(:magnet, seeders: 3, leechers: 5) }
    let!(:magnet_3_4) { FactoryGirl.create(:magnet, seeders: 3, leechers: 4) }
    let!(:magnet_4_1) { FactoryGirl.create(:magnet, seeders: 4, leechers: 1) }
    let!(:magnet_4_3) { FactoryGirl.create(:magnet, seeders: 4, leechers: 3) }
    let!(:magnet_4_2) { FactoryGirl.create(:magnet, seeders: 4, leechers: 2) }
    let!(:magnet_4_5) { FactoryGirl.create(:magnet, seeders: 4, leechers: 5) }
    let!(:magnet_4_4) { FactoryGirl.create(:magnet, seeders: 4, leechers: 4) }
    subject { described_class.batch_to_download }

    it do
      should == [
        magnet_10_5, magnet_10_4, magnet_10_3, magnet_10_1_second,
        magnet_10_1_first,
        magnet_5_5, magnet_5_4, magnet_5_3, magnet_5_2, magnet_5_1,
        magnet_4_5, magnet_4_4, magnet_4_3, magnet_4_2, magnet_4_1,
        magnet_3_5, magnet_3_4, magnet_3_3, magnet_3_2, magnet_3_1
      ]
    end
  end

  describe 'liking' do
    after { subject.update_attribute(:like, true) }

    context 'when downloaded' do
      subject { FactoryGirl.create(:magnet_downloaded) }

      it 'should not download' do
        MagnetDownloadWorker.should_not_receive(:perform_async)
      end
    end

    context 'when not downloaded' do
      it 'should not download' do
        MagnetDownloadWorker.should_receive(:perform_async).with(subject.id)
      end
    end

    context 'when already liked' do
      subject { FactoryGirl.create(:magnet_liked) }

      it 'should not download' do
        MagnetDownloadWorker.should_not_receive(:perform_async)
      end
    end
  end

  describe '.download_timeout!' do
    before do
      described_class.download_timeout!(subject.id)
      subject.reload
    end

    its(:download_timeouted?) { should be_true }
  end

  describe '.download_error!' do
    before do
      described_class.download_error!(subject.id)
      subject.reload
    end

    its(:download_errored?) { should be_true }
  end

  describe '.download!' do
    before do
      BitTorrent.should_receive(:download!).with(
        subject.link,
        upload_rate_limit: '10000K',
        seed_time: 3600,
        connect_timeout: 600,
        timeout: 600,
        use_tor_proxy: true,
        destination_directory:
          "#{MagnetTmpDir::PATH}/#{subject.id}"

      # TODO: investigate why 'any_number_of_times' is need
      ).any_number_of_times.and_return(true)
      described_class.download!(subject.id)
      subject.reload
    end

    its(:downloaded?) { should be_true }
  end

  context 'when magnet has no seeders' do
    subject { FactoryGirl.create(:magnet_without_seeders) }

    its(:seeders?) { should be_false }

    its(:no_seeders?) { should be_true }
  end

  its(:seen) { should be_false }

  its(:like) { should be_false }

  describe '#like!' do
    before { subject.like! }

    its(:seen) { should be_true }

    its(:like) { should be_true }
  end

  describe '.enqueue_download!' do
    before do
      described_class.should_receive(:have_disk_space?).and_return(
        have_disk_space
      )
    end
    after { described_class.enqueue_download! }

    context 'when have disk space' do
      let(:have_disk_space) { true }
      before do
        described_class.should_receive(:batch_to_download).and_return([magnet])
      end

      it 'should like! magnets in batch_to_download' do
        magnet.should_receive(:like!)
      end
    end

    context 'when not have disk space' do
      let(:have_disk_space) { false }
      before do
        described_class.should_not_receive(:batch_to_download)
      end

      it 'should like! magnets in batch_to_download' do
        magnet.should_not_receive(:like!)
      end
    end
  end

  describe '.have_disk_space?' do
    before do
      MagnetTmpDir.should_receive(:have_disk_space?).and_return(
        tmp_dir_have_disk_space
      )
    end
    subject { described_class.have_disk_space? }

    context 'when download tmp directory have no disk space' do
      let(:tmp_dir_have_disk_space) { false }

      it { should be_false }
    end

    context 'when download tmp directory have disk space' do
      let(:tmp_dir_have_disk_space) { true }
      before do
        FreeDiskSpace.should_receive(:gigabytes).with(
          Rails.configuration.magnet_download_finished_dir
        ).and_return(finished_free_space)
      end

      context 'and have 2000 GB free or less on download finished directory' do
        let(:finished_free_space) { 2000.0 }

        it { should be_false }
      end

      context 'and have >2000 GB free on download finished directory' do
        let(:finished_free_space) { 2000.1 }

        it { should be_true }
      end
    end
  end
end
