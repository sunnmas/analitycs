class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  def authenticate_user!
    return if session[:user]&.[]('admin') == true
    flash[:alert] = 'User authorization reuquired'
    redirect_to login_path
  end

  def access_denied(x)
    reset_session
    redirect_to :root
  end

  def logout
    reset_session
    redirect_to :root
  end

  def current_user
    User.find session[:current_user_id] rescue nil
  end

  def authenticate
    # if !verify_recaptcha(action: 'login', minimum_score: 0.6)
    #   @error = t('errors.messages.recaptcha')
    #   render :login
    #   return
    # end
    user = User.find_by_email_password(email: params[:user][:email].downcase, password: params[:user][:password])
    if user
      session[:user] = {'admin' => true}
      session[:current_user_id] = user.id
      redirect_to admin_dashboard_path
    else
      @error = 'Sign in failed'
      render :login
    end
  end

  def debug
    @error_id = params['error_id'] || 'last_error'
    @exception = ErrorLogger.debug @error_id
    if @exception.blank?
      flash.now[:alert] = "Exception #{@error_id} not find in storage"
    end
  end
  private
  def set_locale
    I18n.locale = 'en'
  end
end
