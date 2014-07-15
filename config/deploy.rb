set :application, "myvod"
set :rvm_ruby_string, "2.0.0@#{application}"
set :the_server, "my-vod.eu"

set :the_site, "http://#{the_server}"

role :web, the_server
role :app, the_server
role :db,  the_server, :primary => true

set :user, application
ssh_options[:port] = 22

set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :deploy_to, "/home/#{user}"

set :rails_env, "production"
set :shared_path, "#{deploy_to}/shared"

set :use_sudo, false

require "rvm/capistrano"
require "bundler/capistrano"

before 'deploy:restart', 'service:restart'
after 'deploy:start', 'service:restart'

namespace :service do
  task :restart do
    run "sudo /etc/init.d/myvod restart"
  end
end

namespace :nginx do
  task :restart do
    run "sudo /etc/init.d/nginx restart"
  end
end

namespace :deploy do
  task :pipeline_precompile do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile"
  end

  desc "Link production database.yml"
  task :link_production_db_config do
    run "ln -sf #{release_path}/config/database.yml.example #{release_path}/config/database.yml"
  end

  desc "Link shared var files"
  task :link_var do
    run "ln -sf #{shared_path}/var #{release_path}/public/system"
  end
end

after "deploy:create_symlink", "deploy:pipeline_precompile"
after "deploy:create_symlink", "deploy:migrate"
after "deploy:create_symlink", "deploy:link_var"
after "deploy", "nginx:restart"

require './config/boot'
system("rm -rf public/system") if File.directory?("public/system")
system("rm -rf coverage") if File.directory?("coverage")
system("rake tmp:clear")

require 'sidekiq/capistrano'
set :sidekiq_processes, 1
