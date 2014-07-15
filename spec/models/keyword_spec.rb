require 'spec_helper'

describe Keyword do

  before do
    MagnetSourceImportWorker.stub(:perform_async)
  end

  let(:categories) { [100] }
  let(:keyword) { 'example' }

  subject do
    FactoryGirl.build(:keyword, categories: categories, keyword: keyword)
  end

  it { subject.save! }

  Keyword::VALID_CATEGORIES.each do |valid_category|
    context "when categories is [#{valid_category}]" do
      let(:categories) { [valid_category] }

      its(:valid?) { should be_true }
    end
  end

  context 'when categories nil' do
    let(:categories) { nil }

    its(:valid?) { should be_false }
  end

  context 'when categories empty' do
    let(:categories) { [] }

    its(:valid?) { should be_false }
  end

  context 'when categories contain invalid category' do
    let(:categories) { [999] }

    its(:valid?) { should be_false }
  end

  context 'when keyword nil' do
    let(:keyword) { nil }

    its(:valid?) { should be_false }
  end

  context 'when keyword empty' do
    let(:keyword) { '' }

    its(:valid?) { should be_false }
  end

  context 'when keyword non unique' do
    let(:existing_keyword) { FactoryGirl.create(:keyword) }
    let(:keyword) { existing_keyword.keyword }

    its(:valid?) { should be_false }
  end

end
