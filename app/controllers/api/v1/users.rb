module API
  module V1
    class UserExpose < Grape::Entity
      expose :id, documentation: {type: 'Integer', desc: 'User identifier'}
    end

    class Token < UserExpose
      expose :token, documentation: { type: 'String', desc: 'API token' }
    end

    class Balance < UserExpose
      expose :balance do |user|
        {rub: user.balance[:rub].value, usd: user.balance[:usd].value}
      end
      expose :payout_methods
    end

    class Profile < UserExpose
      expose :token, documentation: { type: 'String', desc: 'API token' }, if: {token: true}
      expose :balance do |user|
        {rub: user.balance[:rub].value, usd: user.balance[:usd].value}
      end
      expose :email, documentation: { type: 'String', desc: 'User Email' }
      expose :role, documentation: { type: 'String', desc: 'User role in system' }
      expose :accept_mail, documentation: { type: 'Boolean', desc: 'User subscription on news' }
      expose :utc, documentation: { type: 'Integer', desc: 'User time zone' }
      expose :locale, documentation: { type: 'String', desc: 'User language' }
      expose :referral_code, documentation: { type: 'String', desc: 'User code for referrals' }
      expose :login_count, documentation: { type: 'Integer', desc: 'User sign in count' }
      expose :payout_methods, documentation: { type: 'String', desc: 'User available methods for payout' }
      expose(:login_at) { |model, options| model.login_at&.localtime(options[:utc] * 3600) }
      expose(:created_at) { |model, options| model.created_at.localtime(options[:utc] * 3600) }
    end

    class Users < Grape::API
      include API::V1::Defaults

      resource :users do
        desc 'Authorize user by email and password'
        params do
          requires :email,    type: String, desc: 'User email'
          requires :password, type: String, desc: 'User password'
        end
        get :sign_in do
          params = api_params.permit(:email, :password)
          user = User.find_by_email_password(email: params[:email]&.downcase, password: params[:password])
          error!({code: 401, message: I18n.t('user.sign_in_failed')}, 200) unless user.present?
          user.login_count += 1
          user.login_at = Time.now
          user.save validate: false
          present(user, with: API::V1::Profile, token: true, root: :user, utc: user.utc)
        end

        desc 'Authorize as user'
        params do
          requires :id, type: String, desc: 'User identifier'
        end
        get :sign_in_as do
          user = User.find api_params[:id]
          Log.ger "Sign in as: #{@user.role} #{@user.id} to sign in as #{user.role} #{user.id}"
          if !@user.role.in?([User::ROLE_ADMIN, User::ROLE_ACCOUNTANT, User::ROLE_MANAGER, User::ROLE_DEVELOPER]) ||
              @user.role <= user.role

            error!({code: 403, message: I18n.t('user.not_enough_rights')}, 200)
          end
          present(user, with: API::V1::Profile, token: true, root: :user, utc: user.utc)
        end

        desc 'Sign up user'
        params do
          requires :email,            type: String,  desc: 'User email'
          requires :password,         type: String,  desc: 'User password'
          requires :accept_mail,      type: Boolean, desc: 'Subscribe on mail news'
          optional :referral_code,    type: String,  desc: 'Referral code'
          optional :registration_url, type: String,  desc: 'Registration URL'
          optional :utm,              type: String,  desc: 'URL with UTM labels'
        end
        post :sign_up do
          params = api_params.permit(:email, :password, :accept_mail, :referral_code, :registration_url, :utm)
          params[:login_count] = 1
          params[:login_at] = Time.now
          params[:locale] = @locale
          params[:registration_locale] = @locale
          params.select! {|key, value| value != nil && value != ''}
          user = User.create params
          if user.errors.messages.blank? && user.persisted?
            present(user, with: API::V1::Profile, token: true, root: :user, utc: user.utc)
          else
            error!({code: 422, message: user.errors.messages_single}, 200)
          end
        end

        desc 'Generate password if user forgot it'
        params do
          requires :email, type: String, desc: 'User email'
        end
        post :generate_password do
          user = User.find_by email: params[:email]
          if user.present?
            user.generate_password
            present({message:  I18n.t('user.new_password.generated')})
          else
            error!({code: 404, message: I18n.t('user.not_found')}, 200)
          end
        end

        desc 'Confirm generate password'
        params do
          requires :password_token, type: String, desc: 'Token for update password (not API token)'
        end
        post :confirm_generated_password do
          if user = User.confirm_generated_password(params[:password_token])
            present(user, with: API::V1::Profile, token: true,
                                                  message: I18n.t('user.new_password.confirmed'),
                                                  root: :user, utc: user.utc)
          else
            error!({code: 403, message: I18n.t('user.new_password.token_rejected')}, 200)
          end
        end

        desc 'Update token'
        post :update_token do
          @user.update_token
          present(@user, with: API::V1::Token, root: :user, utc: @utc)
        end

        desc "Show current user info"
        get :profile do
          present(@user, with: API::V1::Profile, token: false, root: :user, utc: @utc)
        end

        desc "Update current user info"
        params do
          requires :utc,          type: Integer, desc: 'User time zone'
          requires :accept_mail,  type: Boolean, desc: 'Subscribe on mail news'
          requires :locale,       type: String,  desc: 'Notifications language'
          optional :old_password, type: String,  desc: 'Old password'
          optional :password,     type: String,  desc: 'New password'
        end
        patch :update_profile do
          @user.update api_params.permit(:locale, :utc, :accept_mail)
          if @user.errors.messages.present?
            error!({code: 422, message: @user.errors.messages_single}, 200)
          end

          if params[:old_password].present? || params[:password].present?
            unless @user.update_password params[:old_password], params[:password]
              error!({code: 422, message: @user.errors.messages_single}, 200)
            end
          end
          present(@user, with: API::V1::Profile, token: false, root: :user, utc: @utc)
        end
      end
    end
  end
end
