class OauthRegistrationsController < DeviseController
  layout 'auth'

  before_action :check_enabled_registrations
  before_action :require_omniauth_auth
  before_action :require_no_authentication

  def new
    @oauth_registration = Form::OauthRegistration.from_omniauth_auth(omniauth_auth)
  end

  def create
    @oauth_registration = Form::OauthRegistration.from_omniauth_auth(omniauth_auth)
    @oauth_registration.assign_attributes(
      params.require(:form_oauth_registration).permit(:email, :username, :password, :password_confirmation).merge(locale: I18n.locale)
    )

    if @oauth_registration.save
      sign_in(@oauth_registration.user)
      redirect_to web_path
      flash[:notice] = I18n.t('oauth_registration.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def omniauth_auth
    @omniauth_auth ||= session[:devise_omniauth_auth].try(:deep_symbolize_keys)
  end

  def check_enabled_registrations
    redirect_to root_path if single_user_mode? || !Setting.open_registrations
  end

  def require_omniauth_auth
    redirect_to root_path unless omniauth_auth
  end
end
