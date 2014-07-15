require 'spec_helper'

describe BadWord do
  subject { FactoryGirl.build(:bad_word, word: word) }

  context 'when word is nil' do
    let(:word) { nil }

    its(:valid?) { should be_false }
  end

  context 'when word is empty string' do
    let(:word) { '' }

    its(:valid?) { should be_false }
  end

  context 'when word is existing' do
    let!(:existing_word) { FactoryGirl.create(:bad_word) }
    let(:word) { existing_word.word }

    its(:valid?) { should be_false }

    context 'when trying to set existing word by update attribute' do
      subject { FactoryGirl.create(:bad_word) }

      it 'should not allow to set it via update attribute' do
        expect do
          subject.update_attribute(:word, word)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  context 'when word is upcase' do
    let(:word) { 'EXAMPLE' }

    describe 'save' do
      before { subject.save }

      its(:word) { should == 'example' }
    end

    describe 'validation' do
      before { subject.valid? }

      its(:word) { should == 'example' }
    end
  end

end
