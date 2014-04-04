# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'redmine'
set :repo_url, 'git@github.com:cwheart/redmine.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/www/redmine'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/puma.rb public/assets/manifest.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets tmp/states vendor/bundle public/system public/assets assets_manifest_backup}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  # desc 'Init redmine'
  # task :init do
  #   on roles(:app) do
  #     execute :cd, "#{deploy_to}/current/"
  #     execute :rake, 'db:create'
  #     execute :rake, 'db:migrate'
  #     execute :rake, 'redmine:load_default_data'
  #   end
  # end

  desc 'Start application'
  task :start do
    on roles(:app) do
      rails_env=fetch(:default_env)[:rails_env].to_s
      execute "cd #{deploy_to}/current/ && ( RAILS_ENV=#{rails_env} /usr/local/rvm/bin/rvm 2.0.0 do bundle exec bin/puma -C config/puma.rb )"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      rails_env=fetch(:default_env)[:rails_env].to_s
      execute "cd #{deploy_to}/current/ && ( RAILS_ENV=#{rails_env} /usr/local/rvm/bin/rvm 2.0.0 do bundle exec bin/pumactl -S tmp/states/puma.state restart )"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app) do
      rails_env=fetch(:default_env)[:rails_env].to_s
      execute "cd #{deploy_to}/current/ && ( /usr/local/rvm/bin/rvm 2.0.0 do bundle exec bin/pumactl -S tmp/states/puma.state stop )"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
