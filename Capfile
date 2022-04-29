require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
require 'sshkit/sudo'
require 'dotenv/load'
install_plugin Capistrano::SCM::Git
Dir.glob('lib/capistrano/*.rake').each { |r| import r }
