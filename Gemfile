source 'https://rubygems.org'

gem 'rails', '4.0.1'
gem 'activerecord-deprecated_finders', github: 'rails/activerecord-deprecated_finders'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'sprockets-rails', github: 'rails/sprockets-rails'
  gem 'sass-rails',   github: 'rails/sass-rails'
  gem 'coffee-rails', github: 'rails/coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'

  gem 'bootstrap-sass-rails'
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', group: :development

# To use debugger
# gem 'debugger'

gem 'paperclip-ffmpeg'
gem 'kaminari'
gem 'flag_shih_tzu'
gem 'awesome_flags'

gem 'thepiratebay', :git => 'https://github.com/pr0d1r2/thepiratebay.git'
gem 'ruby_bittorrent'

gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'sidekiq-limit_fetch'
gem 'sidekiq-failures'
gem 'sidekiq-status'
gem 'sidetiq'

gem 'free_disk_space'

gem 'workflow'

gem 'paranoia', '~> 2.0'

gem 'protected_attributes'

group :development do
  gem 'foreman'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'sandi_meter'
  gem 'pry'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard'
  gem 'guard-rspec', :require => false
end

group :test do
  gem 'rspec-rails'
  gem 'steak'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'capybara-user_agent', :git => 'https://github.com/kanechika7/capybara-user_agent.git'
  gem 'launchy'
  gem 'rspec-sidekiq'
end

group :test, :development do
  gem 'awesome_print'
  gem 'rails_best_practices'
  gem 'rubocop'
  gem 'gemsurance'
end
