require 'acceptance/acceptance_helper'

feature 'Videos', %q{
  In order to serve videos
  As an anonymous user
  I want to see videos
} do

  set(:video) { FactoryGirl.create(:video_one_second) }

  let(:size) { Video::FORMATS.values.first }
  let(:width) { size.split('x').first }
  let(:height) { size.split('x').last }
  let(:streamable_video_xpath) do
    '//video' +
    "[@controls='controls']" +
    "[@autobuffer='autobuffer']"
  end
  let(:video_xpath) do
    streamable_video_xpath +
    "[@width='#{width}']" +
    "[@height='#{height}']"
  end

  context 'when having one long video' do
    scenario 'i can see details' do
      FactoryGirl.create(:video)
      big_video = Video.last
      big_video.duration.should eq('00:01:25.50')
      big_video.seconds.should eq(85)
      big_video.seen.should be_false
      Video.unseen.should_not be_empty

      visit videos_path

      click_link 'show first unseen'
      within(:xpath, thumbnails_xpath) do
        page.should have_content('00:00:03')
      end

      visit video_path(big_video)
      big_video.update_attribute(:seen, false)
      find(:xpath, "(//a[text()='show next unseen'])[1]").click

      visit video_path(big_video)

      # have thumbnails
      within(:xpath, thumbnails_xpath) do
        %w(00:00:00 00:00:03 00:00:07 00:00:10
           00:00:14 00:00:17 00:00:21 00:00:24
           00:00:28 00:00:31 00:00:35 00:00:38
           00:00:42 00:00:46 00:00:49 00:00:53
           00:00:56 00:01:00 00:01:03 00:01:07
           00:01:10 00:01:14 00:01:17 00:01:21).each do |ss|
          page.should have_content(ss)
        end
      end

      # have video headers
      within(:xpath, controls_xpath) do
        # page.should have_content('iphone4 (960x640)')
        # page.should have_content('iphone (640x480)')
        page.should have_content("ipod (#{size})")
        page.should have_content('Like')
      end

      big_video.destroy!
    end
  end

  context 'when having one unseen video' do
    before { video.update_attribute(:seen, false) }

    describe 'Videos index' do
      let(:welcome_page_link) { 'v' }
      let(:handful_link) { '/v' }
      let(:index_path) { videos_path }

      it 'show video when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'show video when navigating via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'navigate to video' do
        visit index_path
        page.find(:xpath, "//img[@alt='One second']/..").click
        page.should have_xpath(video_xpath)
        video_should_be_seen
        video.reload.seen.should be_true
      end
    end

    describe 'Unseen index' do
      let(:welcome_page_link) { 'u' }
      let(:handful_link) { '/u' }
      let(:index_path) { unseens_path }

      it 'show video when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'show video when navigating via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'navigate to video' do
        visit index_path
        page.find(:xpath, "//img[@alt='One second']/..").click
        page.should have_xpath(video_xpath)
        video_should_be_seen
        video.reload.seen.should be_true
      end
    end

    describe 'Likes index' do
      let(:welcome_page_link) { 'l' }
      let(:handful_link) { '/l' }
      let(:index_path) { unseens_path }

      it 'do not show any video via welcome page link' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end

      it 'do not show any video via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end
    end

    describe 'Show first unseen' do
      scenario 'shows video' do
        visit unseen_path(1)
        page.should have_xpath(video_xpath)
      end
    end
  end

  context 'when having one seen video' do
    before { video.update_attribute(:seen, true) }

    describe 'Videos index' do
      let(:welcome_page_link) { 'v' }
      let(:handful_link) { '/v' }
      let(:index_path) { videos_path }

      it 'show video when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'show video when navigating via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'navigate to video' do
        visit index_path
        page.find(:xpath, "//img[@alt='One second']/..").click
        page.should have_xpath(video_xpath)
        video_should_be_seen
        video.reload.seen.should be_true
      end
    end

    describe 'Unseen index' do
      let(:welcome_page_link) { 'u' }
      let(:handful_link) { '/u' }
      let(:index_path) { unseens_path }

      it 'do not show any video via welcome page link' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end

      it 'do not show any video via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end
    end

    describe 'Likes index' do
      let(:welcome_page_link) { 'l' }
      let(:handful_link) { '/l' }
      let(:index_path) { unseens_path }

      it 'do not show any video via welcome page link' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end

      it 'do not show any video via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end
    end

    describe 'Show first unseen' do
      scenario 'redirects to videos index' do
        visit unseen_path(1)
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      context 'when on iphone' do
        before { set_user_agent(:iphone) }

        scenario 'renders videos index' do
          visit unseen_path(1)
          page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
          page.should have_xpath("//img[@alt='One second']/..")
        end
      end

      context 'when have liked video' do
        before { video.update_attribute(:like, true) }
        after { video.update_attribute(:like, false) }

        scenario 'redirects to videos index' do
          visit unseen_path(1)
          page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
          page.should have_xpath("//img[@alt='One second']/..")
        end

        context 'when on iphone' do
          before { set_user_agent(:iphone) }

          scenario 'redirects to videos index' do
            visit unseen_path(1)
            page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
            page.should have_xpath("//img[@alt='One second']/..")
          end
        end
      end
    end
  end

  context 'when having one unseen video' do
    before { video.update_attribute(:seen, false) }

    describe 'Show first unseen' do
      scenario 'redirects to videos index' do
        visit unseen_path(1)
        page.should have_xpath(video_xpath)
      end

      context 'when on iphone' do
        before { set_user_agent(:iphone) }

        scenario 'renders videos index' do
          visit unseen_path(1)
          page.should have_xpath(video_xpath)
        end
      end
    end
  end

  context 'when having one not liked video' do
    before { video.update_attribute(:like, false) }

    scenario 'can like video' do
      visit video_path(video)
      within(:xpath, controls_xpath) do
        find('#video_like').should_not be_checked
        check('Like')
        click_on('submit')
      end
      Video.last.like.should be_true
    end

    describe 'Likes index' do
      let(:welcome_page_link) { 'l' }
      let(:handful_link) { '/l' }
      let(:index_path) { unseens_path }

      it 'do not show any video via welcome page link' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end

      it 'do not show any video via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should_not have_xpath("//img[@alt='One second']/..")
      end
    end
  end

  context 'when having one liked video' do
    before { video.update_attribute(:like, true) }

    scenario 'can unlike video' do
      visit video_path(video)
      within(:xpath, controls_xpath) do
        find('#video_like').should be_checked
        uncheck('Like')
        click_on('submit')
      end
      Video.last.like.should be_false
    end

    describe 'Likes index' do
      let(:welcome_page_link) { 'l' }
      let(:handful_link) { '/l' }
      let(:index_path) { unseens_path }

      it 'show video when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'show video when navigating via handful link' do
        visit handful_link
        page.should have_xpath("//h1[contains(text(), \"Videos Index\")]")
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'navigate to video' do
        visit index_path
        page.find(:xpath, "//img[@alt='One second']/..").click
        page.should have_xpath(video_xpath)
        video_should_be_seen
        video.reload.seen.should be_true
      end
    end
  end

  scenario 'open second page of videos' do
    visit '/videos?page=2'
  end

  context 'when having one not bestd video' do
    before { video.update_attribute(:best, false) }

    scenario 'can best video' do
      visit video_path(video)
      within(:xpath, controls_xpath) do
        find('#video_best').should_not be_checked
        check('Best')
        click_on('submit')
      end
      Video.last.best.should be_true
    end

    describe 'Bests index' do
      let(:welcome_page_link) { 'b' }
      let(:handful_link) { '/b' }
      let(:index_path) { unseens_path }

      it 'do not show any video via welcome page link' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath('//h1[contains(text(), "Videos Index")]')
        page.should_not have_xpath("//img[@alt='One second']/..")
      end

      it 'do not show any video via handful link' do
        visit handful_link
        page.should have_xpath('//h1[contains(text(), "Videos Index")]')
        page.should_not have_xpath("//img[@alt='One second']/..")
      end
    end
  end

  context 'when having one bestd video' do
    before { video.update_attribute(:best, true) }

    scenario 'can unbest video' do
      visit video_path(video)
      within(:xpath, controls_xpath) do
        find('#video_best').should be_checked
        uncheck('Best')
        click_on('submit')
      end
      Video.last.best.should be_false
    end

    describe 'Bests index' do
      let(:welcome_page_link) { 'b' }
      let(:handful_link) { '/b' }
      let(:index_path) { unseens_path }

      it 'show video when navigating from welcome page' do
        visit homepage
        click_link welcome_page_link
        page.should have_xpath('//h1[contains(text(), "Videos Index")]')
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'show video when navigating via handful link' do
        visit handful_link
        page.should have_xpath('//h1[contains(text(), "Videos Index")]')
        page.should have_xpath("//img[@alt='One second']/..")
      end

      it 'navigate to video' do
        visit index_path
        page.find(:xpath, "//img[@alt='One second']/..").click
        page.should have_xpath(video_xpath)
        video_should_be_seen
        video.reload.seen.should be_true
      end
    end
  end

  def video_should_be_seen
    within(:xpath, controls_xpath) do
      find('#video_seen').should be_checked
    end
  end

  def controls_xpath
    '//ul[2]'
  end

  def thumbnails_xpath
    '//ul[3]'
  end

end
