lock '3.16.0'

set :application, 'analytics'
set :user, 'deployer'

if ENV['branch'].nil? || ENV['branch'].empty?
  set :branch, 'master'
else
  set :branch, ENV['branch']
end

set :repo_url, "https://github.com/sunnmas/analitycs.git"
set :repository_cache, 'git_cache'
set :deploy_to, '/var/www/analytics'
set :log_level, :debug
set :keep_releases, 15

#database:
# secrets = YAML.load(`rails credentials:show --environment #{fetch(:stage)}`)
# set :database,          secrets['postgres']['database']
# set :database_user,     secrets['postgres']['username']
# set :database_password, secrets['postgres']['password']
