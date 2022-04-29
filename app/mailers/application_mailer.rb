class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  layout 'mailer'
  default from: Rails.application.credentials.smtp[:from]

  def self.delay
    if Rails.env.production?
      rand(20..400).seconds
    else
      rand(0..90).seconds
    end
  end
end
