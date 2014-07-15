require 'acceptance/acceptance_helper'

feature 'Likes', %q{
  In order to serve likes videos
  As an anonymous user
  I want to see likes videos
} do

  scenario 'open second page of likes' do
    visit '/likes?page=2'
  end

end
