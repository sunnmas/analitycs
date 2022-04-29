app_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH.unshift(app_path) unless $LOAD_PATH.include?(app_path)

require 'clockwork'
require 'config/boot'
require 'config/environment'

module Clockwork

end
