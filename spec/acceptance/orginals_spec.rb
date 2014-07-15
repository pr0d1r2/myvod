
require 'acceptance/acceptance_helper'

feature 'Orginals', %q{
  In order to serve videos orginals
  As an anonymous user
  I want to see videos
} do

  let(:streamable_video_xpath) do
    '//video' +
    "[@controls='controls']" +
    "[@autobuffer='autobuffer']"
  end

  context 'when have video with streamable orginal' do
    set(:video) { FactoryGirl.create(:video_streamable) }

    it 'navigate to video' do
      visit videos_path
      page.find(:xpath, "//img[@alt='Streamable']/..").click
      page.should have_xpath(streamable_video_xpath)
      within(:xpath, '//ul[2]') do
        find('#video_seen').should be_checked
      end
      video.reload.seen.should be_true
      click_link('Show Detailed')
      within(:xpath, '//h2[1]') do
        page.should have_content('Detailed')
      end
    end
  end

end
