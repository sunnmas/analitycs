url = 'redis://localhost:6379/0'
url = 'redis://redis:6379/0' if Rails.env.production? || Rails.env.staging?
Sidekiq.default_worker_options = { retry: 0 }
Sidekiq.configure_server do |config|
  config.redis = { url: url }
end
Sidekiq.configure_client do |config|
  config.redis = { url: url }
end

require 'sidekiq/api'
module Sidekiq
  class ScheduledSet < JobSet
    def self.delete_jobs(jids:)
      self.new.each { |job| job.delete if job.jid.in? jids }
    end
  end
end
