namespace :db do

  desc 'Create development database from scratch and prepare test database'
  task :bootstrap do
    raise "Database bootstrap blocked in production !!!" if ENV['RAILS_ENV'] == "production"
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['db:test:clone'].invoke
  end

end
