module API
  module V1

    module Defaults
      extend ActiveSupport::Concern
      SKIP_AUTH_METHODS = [
          '/api/v1/users/sign_in',
          '/api/v1/users/sign_up',
          '/api/v1/users/generate_password',
          '/api/v1/users/confirm_generated_password',
      ]

      included do
        version 'v1'
        format :json

        before do
          @user = User.find_by_token(headers['Authorization'])
          error!({ code: 401, message: I18n.t('user.authorization_required')}, 200) unless user_authorized?
        end

        helpers do
          def api_params
            @api_params ||= ActionController::Parameters.new(params)
          end

          def user_authorized?
            return true unless @user.nil?
            SKIP_AUTH_METHODS.include?(@env['PATH_INFO'])
          end

          def current_user
            @user
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error!({code: 404, message: I18n.t('errors.messages.not_found')}, 200)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          message = {}
          e.message.split('=, ').each do |validation|
            param, error = validation.split('=')
            message[param] = error
          end
          error!({code: 400, message: message}, 200)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error!({code: 400, message: e.message}, 200)
        end

        rescue_from :all do |e|
          if Rails.env.development? || Rails.env.test?
            if single_test?
              puts "Internal server error: #{e.message}"
              e.backtrace.each {|line| puts line}
            end
            error_response(message: {description: "Internal server error: #{e.message}", error_id: ErrorLogger.log(e)},
                           status: 200)
          else
            ExceptionNotifier.notify_exception e
            error_response(message: {description: "Internal server error", error_id: ErrorLogger.log(e)}, status: 200)
          end
        end
      end
    end
  end
end
