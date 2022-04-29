require 'highline'
namespace :project do
  task :copy_key do
    on roles :all do
      execute "cp ~/#{fetch(:stage)}.key #{fetch(:deploy_to)}/shared/"
    end
  end

  task :copy_key_to_release do
    on roles :all do
      execute "cp #{fetch(:deploy_to)}/shared/#{fetch(:stage)}.key #{fetch(:deploy_to)}/current/config/credentials" rescue nil
    end
  end

  task :create_directories do
    on roles :all do
      sudo :mkdir, "-p /var/www"
      sudo :chown, 'deployer:deployer /var/www'
      execute "mkdir -p #{fetch(:deploy_to)}/shared/db/redis"
      execute "mkdir -p #{fetch(:deploy_to)}/shared/db/pg/data"
      execute "mkdir -p #{fetch(:deploy_to)}/shared/db/pg/backups"
      execute "ln -s #{fetch(:deploy_to)}/shared ~" rescue nil
    end
  end

  task :release_files do
    on roles :all do
      execute "ln -s #{fetch(:deploy_to)}/current ~" rescue nil
      execute "cp #{fetch(:deploy_to)}/revisions.log #{fetch(:deploy_to)}/current" rescue nil
      execute "mkdir -p #{fetch(:deploy_to)}/current/tmp" rescue nil
    end
  end

  task :setup_env do
    on roles :all do
      rails_image_version = "#{capture("cat #{fetch(:deploy_to)}/current/REVISION")}"
      envfile = "#{fetch(:deploy_to)}/current/.env"
      execute :touch, envfile
      execute :echo, "\"RAILS_IMAGE_VERSION='#{rails_image_version}'\" >> #{envfile}"
      execute :echo, "\"RELEASE_PATH='#{release_path}'\" >> #{envfile}"
      execute :echo, "\"DEPLOY_PATH='#{fetch(:deploy_to)}'\" >> #{envfile}"
      execute :echo, "\"STAGE='#{fetch(:stage)}'\" >> #{envfile}"
      execute :echo, "\"DATABASE_NAME='#{fetch(:database)}'\" >> #{envfile}"
      execute :echo, "\"DATABASE_USER='#{fetch(:database_user)}'\" >> #{envfile}"
      execute :echo, "\"DATABASE_PASS='#{fetch(:database_password)}'\" >> #{envfile}"
    end
  end

  task :generate_ssl do
    on roles :all do
      execute :bash, "#{release_path}/config/docker/certbot/init.#{fetch(:stage)}.sh"
    end
  end
  # after :create_directories, :copy_key

  before :deploy, 'deploy:ssh_add'
  # # before :deploy, 'deploy:sudo'
  before :deploy, 'project:create_directories'
  after  :deploy, 'docker:build'
  # after  :release_files, :copy_key_to_release
end
