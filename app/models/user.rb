class User < ApplicationRecord
  MIN_PASSWORD_LENGTH = 8
  MAX_PASSWORD_LENGTH = 1024
  TOKEN_HALF_LENGTH = 50

  strip_attributes

  validates :email, presence: true, uniqueness: {message: "Не уникально"},
                    format: { with: $EMAIL_FORMAT }
  validates :password, presence: true, length: { minimum: MIN_PASSWORD_LENGTH, maximum: MAX_PASSWORD_LENGTH}
  validates :token, length: { minimum: 2*TOKEN_HALF_LENGTH }, format: { with: /\A\d*\:[a-f0-9]+\z/ }


  def self.create(attributes = nil, &block)
    if attributes.present?
      attributes[:token] = User.generate_token if attributes[:token].blank?
      attributes[:email] = attributes[:email].downcase if attributes[:email].present?
      if attributes[:referral_code].present?
        code = attributes[:referral_code]
        attributes.delete :referral_code
        id = code[8..-1]
        referral = User.find(id) rescue nil
        attributes[:referral_id] = id if referral&.referral_code == code
      end
    end
    ActiveRecord::Base.transaction do
      @user = super(attributes, &block)
      if @user.persisted?
        password = @user.password
        @user.update_column(:password, Digest::MD5.hexdigest(password)) if password.present?
      end
    end
    @user
  end

  def self.find_by_token(token)
    return nil if token.blank?
    id, _token = token.split(':')
    return nil if id.blank?
    return nil if _token.blank?
    user = find id rescue nil
    return nil if user.blank?
    return user if user.token == token
    nil
  end

  def self.find_by_email_password(email:, password:)
    return nil if email.blank?
    user = find_by email: email
    return nil if user.blank?
    return nil unless user.password_correct?(password)
    user
  end

  def update_token
    return unless self.persisted?
    update_column :token, User.generate_token
    self.token
  end

  def update_password(old_password, new_password)
    remember_password = self.password
    return false unless self.persisted?
    unless password_correct? old_password
      errors.add :old_password, I18n.t('activerecord.errors.models.user.attributes.password.mismatch')
      return false
    end
    self.password = new_password
    self.validate
    if self.errors.messages[:password].present? || self.errors.messages[:old_password].present?
      self.password = remember_password
      return false
    end
    update_column :password, Digest::MD5.hexdigest(new_password)
    true
  end

  def generate_password
    return unless self.persisted?
    @new_password = rand(36**MIN_PASSWORD_LENGTH).to_s(36)
    self.password_token = Digest::MD5.hexdigest(@new_password)
    self.password_token_expires = 1.day.since
    save(validate: false)
    notify :generate_password,
           {new_password: @new_password, password_token: password_token},
           force: true
  end

  def self.confirm_generated_password(pwd_token)
    return false if pwd_token.blank?
    id, _password_token = pwd_token.split(':')
    return false if id.blank?
    return false if _password_token.blank?
    user = find id rescue nil
    return false if user.blank?
    return false if user.password_token_expires&.< Time.now
    return false if user.password_token != pwd_token
    user.password = _password_token
    user.password_token = nil
    user.password_token_expires = nil
    user.save(validate: false)
    user
  end

  def password_correct?(pwd)
    Digest::MD5.hexdigest(pwd) == password rescue false
  end

  def token
    "#{id}:#{super}"
  end

  def password_token
    "#{id}:#{super}" if persisted? && super
  end

  def notify(method, args, force: false, now: false, wait: nil)
    return nil if !(accept_mail || force)
    args.merge!(user: self) if self.persisted?
    mail = UserMailer.send(method, args)
    if now
      mail.deliver_now
    else
      raise I18n.t('errors.messages.invalid') if wait.present? && !wait.is_a?(ActiveSupport::Duration)
      if wait.present?
        mail = mail.deliver_later(wait: wait)
      else
        mail = mail.deliver_later
      end
      return mail
    end
    nil
  end

private

  def self.generate_token
    SecureRandom.hex(TOKEN_HALF_LENGTH)
  end

end
