def single_test?
  ENV['RM_INFO'].present?
end

if Rails.env.test?
  module TestSetup
    def make
      @lorem = $LOREM
      I18n.locale = $LOCALES[rand($LOCALES.size)]
      header('Ch-Locale', I18n.locale) rescue nil
    end
  end

  class TestController < ActionController::TestCase
    include TestSetup
    setup do
      make
    end
  end

  class APIControllerTest < TestController
    include Rack::Test::Methods
    attr_reader :response_body
    setup do
      self.current_session.instance_variable_get(:@rack_mock_session).after_request do
        @response_body = JSON.parse(last_response.body) rescue last_response.body
      end
    end

    def app
      Rails.application
    end

  private
    def unauthorized?
      response_body['result'] == 'failed' &&
        response_body['code'] == 401 &&
        response_body['error'] == I18n.t('user.authorization_required') &&
        response.status == 200
    end
  end

  class ActiveSupport::TestCase
    include TestSetup
    setup do
      make
    end
  end


  module I18n
    def self.exception_raiser(*args)
      exception, locale, key, options = args
      raise "i18n #{exception}"
    end
  end

  I18n.exception_handler = :exception_raiser

  module ParallelTests
    module Tasks
      class << self
        def rake_bin
          'rails'
        end
      end
    end
  end
end
