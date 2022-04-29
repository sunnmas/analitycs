ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factories'
require 'mocha/minitest'
require 'database_cleaner/active_record'

class Minitest::Test
  def before_setup
    super
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner[:active_record, db: :test].clean_with(:truncation)
    DatabaseCleaner.start
  end

  def after_teardown
    super
    DatabaseCleaner.clean
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  fixtures :all
end

MiniTest.after_run {
  FileUtils.rm_rf("#{Rails.root}/public/test/images/db#{ENV['TEST_ENV_NUMBER']}")
  Sidekiq::Queue.all.map(&:clear)
  Sidekiq::ScheduledSet.new.clear
  Sidekiq::DeadSet.new.clear
}

# Minitest reporters не хотят работать с RubyMine при запуске отдельного теста:
Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new]) unless single_test?

# Для тестов джоб:
# https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html#method-i-before_setup
