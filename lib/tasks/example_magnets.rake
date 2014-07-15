desc 'Add example magnets'
task :example_magnets => :environment do
  require 'factory_girl'
  require Rails.root.join('spec/factories/magnet_sources.rb')
  magnet = FactoryGirl.create(:magnet_source)
  magnet.import
end
