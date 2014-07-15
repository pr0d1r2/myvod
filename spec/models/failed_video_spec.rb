require 'spec_helper'

describe FailedVideo do

  let(:md5) { 'a' * 32 }
  let(:failed_video) { FactoryGirl.build(:failed_video, md5: md5) }
  subject { failed_video }

  it { should be_valid }

  context 'when md5 nil' do
    let(:md5) { nil }

    it { should_not be_valid }
  end

  context 'when md5 blank' do
    let(:md5) { '' }

    it { should_not be_valid }
  end

  context 'when md5 is less than 32 chars' do
    let(:md5) { 'a' * 31 }

    it { should_not be_valid }
  end

  context 'when md5 is more than 32 chars' do
    let(:md5) { 'a' * 33 }

    it { should_not be_valid }
  end

  it { subject.save! }

  describe '.from_file' do
    context 'when failed video already exist' do
      let!(:existing) { FactoryGirl.create(:failed_video, :one_second) }

      it 'should return existing' do
        described_class.from_file(
          Rails.root.join('db/seeds/videos/one_second.m4v')
        ).should == existing
      end
    end

    context 'when failed video not exist' do
      it 'should create new' do
        described_class.from_file(
          Rails.root.join('db/seeds/videos/one_second.m4v')
        ).should be_a(FailedVideo)
      end
    end
  end

end
