class AdminMailer < ApplicationMailer
  def self.notify method, args
    recipients = ['service@instajet.io']
    AdminMailer.send(method, args.merge(recipients: recipients)).deliver_later
  end

  def test(args)
    mail to: args[:recipients], subject: 'Test'
  end

private

  def mail(headers = {}, &block)
    headers[:subject] = "[DEV] #{headers[:subject]}" if Rails.env.development?
    headers[:subject] = "[STAG] #{headers[:subject]}" if Rails.env.staging?
    super(headers, &block)
  end
end
