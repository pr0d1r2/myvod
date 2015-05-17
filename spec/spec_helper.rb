require 'simplecov'
SimpleCov.start
SimpleCov.minimum_coverage 100

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl'
require 'sidekiq/testing/inline'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

require 'capybara/user_agent'
Capybara::UserAgent.add_user_agents(iphone: 'iphone')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

require 'fileutils'

def cleanup_download_directories
  if File.exist?(Rails.configuration.magnet_download_tmp_dir)
    FileUtils.rm_rf(Rails.configuration.magnet_download_tmp_dir)
  end
  if File.exist?(Rails.configuration.magnet_download_finished_dir)
    FileUtils.rm_rf(Rails.configuration.magnet_download_finished_dir)
  end
end

def create_download_directories
  unless File.directory?(Rails.configuration.magnet_download_tmp_dir)
    FileUtils.mkdir_p(Rails.configuration.magnet_download_tmp_dir)
  end
  unless File.directory?(Rails.configuration.magnet_download_finished_dir)
    FileUtils.mkdir_p(Rails.configuration.magnet_download_finished_dir)
  end
end

def input_files_directory
  "#{Rails.root}/tmp/test/input_files"
end

def prepare_input_files_directory
  unless File.directory?(input_files_directory)
    FileUtils.mkdir_p(input_files_directory)
  end
end

def cleanup_input_files_directory
  if File.directory?(input_files_directory)
    FileUtils.rm_rf(input_files_directory)
  end
end

def input_directories_directory
  "#{Rails.root}/tmp/test/input_directories"
end

def prepare_input_directories_directory
  unless File.directory?(input_directories_directory)
    FileUtils.mkdir_p(input_directories_directory)
  end
end

def cleanup_input_directories_directory
  if File.directory?(input_directories_directory)
    FileUtils.rm_rf(input_directories_directory)
  end
end

RSpec.configure do |config|
  config.before(:all) do
    DatabaseCleaner.clean
  end

  config.include Capybara::UserAgent::DSL

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:suite) do
    cleanup_download_directories
    create_download_directories
    prepare_input_files_directory
    prepare_input_directories_directory
  end
  config.after(:suite) do
    cleanup_download_directories
    cleanup_input_files_directory
    cleanup_input_directories_directory
  end
end

# do not perform any physical downloads
require 'ruby_bittorrent'
BitTorrent.class_eval do
  def download!
    true
  end
end
