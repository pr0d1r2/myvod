require 'spec_helper'

describe MagnetSource do

  let(:the_object) { FactoryGirl.create(:magnet_source) }
  let(:page) { 1 }

  describe '.import!' do
    let(:magnet_source_id) { 8472 }
    before do
      described_class.should_receive(:find).with(
        magnet_source_id
      ).and_return(the_object)
    end
    after { described_class.import!(magnet_source_id) }

    it 'should import magnets' do
      the_object.should_receive(:import)
    end
  end

  describe '#import' do
    let(:title1) { 'example1 title' }
    let(:results1) do
      [
        {
          title: title1,
          seeders: 48,
          leechers: 24,
          magnet_link: 'magnet:?xt=urn:btih:example1',
          torrent_id: '1',
          category: 'Video',
          url: '/torrent/1/example'
        }
      ]
    end
    let(:title2) { 'example2 title' }
    let(:results2) do
      [
        {
          title: title2,
          seeders: 96,
          leechers: 48,
          magnet_link: 'magnet:?xt=urn:btih:example2',
          torrent_id: '2',
          category: 'Video',
          url: '/torrent/2/example'
        }
      ]
    end
    before do
      Magnet.destroy_all
      the_object.should_receive(:fetch_results).with(1).and_return(results1)
      the_object.should_receive(:fetch_results).with(2).and_return(results2)
      the_object.import
    end

    it 'should create of update magnets with results from ThePirateBay' do
      the_object.magnets.count.should == 2
    end

    it 'should create magnets with proper order' do
      the_object.magnets.first.title.should eq(title1)
      the_object.magnets.last.title.should eq(title2)
    end

    context 'when import magnet with torrent_id in other magnet_source' do
      let(:title3) { 'example3 title' }
      let(:results3) do
        [
          {
            title: title3,
            seeders: 48,
            leechers: 24,
            magnet_link: 'magnet:?xt=urn:btih:example1',
            torrent_id: '1',
            category: 'Video',
            url: '/torrent/1/example'
          }
        ]
      end
      let(:other_magnet_source) do
        FactoryGirl.create(:magnet_source, number_of_pages: 1)
      end
      before do
        other_magnet_source.should_receive(:fetch_results).with(1).and_return(
          results3
        )
      end

      it do
        expect { other_magnet_source.import }.to_not change(Magnet, :count)
      end

      describe 'imported magnets' do
        before { other_magnet_source.import }
        subject { other_magnet_source.magnets }

        it { should == [] }
      end
    end
  end

  describe '#fetch_results' do
    let(:results) { mock('results') }
    let(:pirate_bay_search) { mock('pirate_bay_search') }
    before do
      pirate_bay_search.should_receive(:results).and_return(results)
      the_object.should_receive(:pirate_bay_search).with(page).and_return(
        pirate_bay_search
      )
    end

    it 'should return proper results from pirate_bay_search' do
      the_object.send(:fetch_results, page).should == results
    end
  end

  describe '#pirate_bay_search' do
    let(:pirate_bay_search) { mock('pirate_bay_search') }
    before do
      ThePirateBay::Search.should_receive(:new).with(
        the_object.magnet_keyword,
        page,
        the_object.sort_by,
        the_object.category,
        true
      ).and_return(pirate_bay_search)
    end

    its 'should return proper search' do
      the_object.send(:pirate_bay_search, page) { should == pirate_bay_search }
    end
  end

  context 'when trying to add magnet_keyword already existing for category' do
    let(:existing_object) { the_object }
    subject do
      FactoryGirl.build(
        :magnet_source,
        magnet_keyword: existing_object.magnet_keyword,
        category: existing_object.category
      )
    end

    its(:valid?) { should_not be_true }

    its(:save) { should_not be_true }
  end

  context 'when add UPCASE magnet_keyword existing for category as downcase' do
    let(:existing_object) { the_object }
    subject do
      FactoryGirl.build(
        :magnet_source,
        magnet_keyword: existing_object.magnet_keyword.upcase,
        category: existing_object.category
      )
    end

    its(:valid?) { should_not be_true }

    its(:save) { should_not be_true }
  end

  context 'when add downcase magnet_keyword existing for category as UPCASE' do
    let(:existing_object) { the_object }
    before do
      existing_object.update_attribute(
        :magnet_keyword, existing_object.magnet_keyword.upcase
      )
    end
    subject do
      FactoryGirl.build(
        :magnet_source,
        magnet_keyword: existing_object.magnet_keyword.upcase,
        category: existing_object.category
      )
    end

    its(:valid?) { should_not be_true }

    its(:save) { should_not be_true }
  end

  context 'when trying to add magnet_keyword existing for other category' do
    let(:existing_object) { the_object }
    subject do
      FactoryGirl.build(
        :magnet_source,
        magnet_keyword: existing_object.magnet_keyword,
        category: ThePirateBay::Category::Audio
      )
    end

    its(:valid?) { should be_true }

    its(:save) { should be_true }
  end

  context 'when trying to add empty magnet_keyword' do
    subject { FactoryGirl.build(:magnet_source, magnet_keyword: '') }

    its(:valid?) { should be_false }

    its(:save) { should be_false }
  end

  context 'when trying to add nil magnet_keyword' do
    subject { FactoryGirl.build(:magnet_source, magnet_keyword: nil) }

    its(:valid?) { should be_false }

    its(:save) { should be_false }
  end

  describe 'create magnet sources' do
    subject { FactoryGirl.build(:magnet_source_with_import_async) }

    after { subject.save! }

    it 'should import created magnet sources on sidekiq' do
      pending 'not working yet'
    end
  end

  describe 'import_async' do
    after { subject.send(:import_async) }

    it 'should import created magnet sources on sidekiq' do
      MagnetSourceImportWorker.should_receive(:perform_async).with(subject.id)
    end
  end

end
