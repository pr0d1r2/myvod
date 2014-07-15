require 'acceptance/acceptance_helper'

feature 'Magnets', %q{
  In order to serve magnets
  As an anonymous user
  I want to see magnets
} do

  set(:magnet) { FactoryGirl.create(:magnet) }

  context 'when having one unseen magnet' do
    before { magnet.update_attribute(:seen, false) }

    describe 'Magnets index' do
      let(:welcome_page_link) { 'm' }
      let(:handful_link) { '/m' }
      let(:index_path) { magnets_path }

      it 'show magnet when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath('//h1[contains(text(), "Magnets Index")]')
        page.should have_xpath('//a[contains(text(), "factory magnet")]')
      end

      it 'show magnet when navigating via handful link' do
        visit handful_link
        page.should have_xpath('//h1[contains(text(), "Magnets Index")]')
        page.should have_xpath('//a[contains(text(), "factory magnet")]')
      end

      it 'navigate to magnet' do
        visit index_path
        click_link 'factory magnet'
        page.should have_xpath('//h1[contains(text(), "factory magnet")]')
        page.should have_xpath("//dd[contains(text(), \"#{magnet.id}\")]")
        page.should have_xpath('//dd[contains(text(), "50")]')
        page.should have_xpath('//dd[contains(text(), "30")]')
        find('#magnet_seen').should be_checked
        Magnet.last.seen.should be_true
      end
    end
  end

  context 'when having one seen magnet' do
    before { magnet.update_attribute(:seen, true) }

    describe 'Magnets index' do
      let(:welcome_page_link) { 'm' }
      let(:handful_link) { '/m' }
      let(:index_path) { magnets_path }

      it 'show magnet when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath('//h1[contains(text(), "Magnets Index")]')
        page.should_not have_xpath('//a[contains(text(), "factory magnet")]')
      end

      it 'show magnet when navigating via handful link' do
        visit handful_link
        page.should have_xpath('//h1[contains(text(), "Magnets Index")]')
        page.should_not have_xpath('//a[contains(text(), "factory magnet")]')
      end
    end
  end

  context 'when having one not liked magnet' do
    before { magnet.update_attribute(:like, false) }

    scenario 'can like magnet' do
      visit magnet_path(magnet)
      find('#magnet_like').should_not be_checked
      check('Like')
      click_on('submit')
      Magnet.last.like.should be_true
    end
  end

  scenario 'open second page of magnets' do
    visit '/magnets?page=2'
  end

end
