class ErrorLogger
  if Rails.env.development? or Rails.env.test?
    redis_url = 'redis://127.0.0.1:6379/0/errors'
  else
    redis_url = 'redis://redis:6379/0/errors'
  end
  EXP_TIME = 60*60*24*7 #1 week

  @@redis = Redis.new url: redis_url
  def self.log exception
    error = {message: exception.message, backtrace: exception.backtrace, time: Time.now.inspect}.to_s
    hash = Digest::MD5.hexdigest(error.to_s)
    @@redis.set hash, error, ex: EXP_TIME
    @@redis.set 'last_error', error, ex: EXP_TIME
    hash
  end

  def self.debug exception_id
    eval(@@redis.get(exception_id)) rescue nil
  end
end
