require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

module Analitycs
  class Application < Rails::Application
    $MAIL_FROM = $SITE = 'analityc.io'.freeze
    $VERSION = IO.readlines("#{Rails.root}/revisions.log").last.freeze rescue '1.0.0'.freeze

    $PHONE_FORMAT = /\A\+?([0-9]){10,12}\z/.freeze
    $EMAIL_FORMAT = /\A[a-z0-9]+[-_a-z0-9.]*@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/.freeze
    $URL_FORMAT = /https?:\/\/(www\.)?[-a-z0-9а-я@:%._\+~#=]{1,256}\.[a-z0-9а-я()]{1,11}\b([-a-z0-9а-я()@:%_\+.~#?&\/=]*)/ix.freeze
    $UTC = '+3'.freeze

#=======================================================================================================================
    #TIMEZONE
    config.time_zone = ActiveSupport::TimeZone[$UTC.to_i].name
#=======================================================================================================================
    #MAIL
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              Rails.application.credentials.smtp[:address],
      port:                 Rails.application.credentials.smtp[:port],
      domain:               Rails.application.credentials.smtp[:domain],
      user_name:            Rails.application.credentials.smtp[:user_name],
      password:             Rails.application.credentials.smtp[:password],
      authentication:       Rails.application.credentials.smtp[:authentication],
      ssl:                  Rails.application.credentials.smtp[:ssl],
      enable_starttls_auto: Rails.application.credentials.smtp[:enable_starttls_auto]
    }
    config.action_mailer.show_previews = true

    config.middleware.use ExceptionNotification::Rack,
                          email: {
                            email_prefix: "[#{Rails.env} error] ",
                            sender_address: Rails.application.credentials.smtp_debug[:from],
                            exception_recipients: Rails.application.credentials.smtp_debug[:user_name],
                            delivery_method: :smtp,
                            smtp_settings: {
                              address:              Rails.application.credentials.smtp_debug[:address],
                              port:                 Rails.application.credentials.smtp_debug[:port],
                              domain:               Rails.application.credentials.smtp_debug[:domain],
                              user_name:            Rails.application.credentials.smtp_debug[:user_name],
                              password:             Rails.application.credentials.smtp_debug[:password],
                              authentication:       Rails.application.credentials.smtp_debug[:authentication],
                              ssl:                  Rails.application.credentials.smtp_debug[:ssl],
                              enable_starttls_auto: Rails.application.credentials.smtp_debug[:enable_starttls_auto]
                            }
                          }
#=======================================================================================================================
    #SESSION AND COOKIES
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.session_store :cookie_store
    config.force_ssl = true if Rails.env.production? || Rails.env.staging?
#=======================================================================================================================
    #CORS
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :delete, :patch]
      end
    end
#=======================================================================================================================
    #OTHER
    config.active_job.queue_adapter = :sidekiq
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "#{html_tag}".html_safe }
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += %W["#{config.root}/app/validators/"]
    config.exceptions_app = self.routes
  end
end
