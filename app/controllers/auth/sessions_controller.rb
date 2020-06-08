# frozen_string_literal: true

class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  skip_before_action :require_no_authentication, only: [:create]
  skip_before_action :require_functional!

  include TwoFactorAuthenticationConcern
  include SignInTokenAuthenticationConcern

  before_action :set_instance_presenter, only: [:new]
  before_action :set_body_classes

  def new
    Devise.omniauth_configs.each do |provider, config|
      return redirect_to(omniauth_authorize_path(resource_name, provider)) if config.strategy.redirect_at_sign_in
    end

    super
  end

  def create
    super do |resource|
      remember_me(resource)
      flash.delete(:notice)
    end
  end

  def destroy
    tmp_stored_location = stored_location_for(:user)
    super
    session.delete(:challenge_passed_at)
    flash.delete(:notice)
    store_location_for(:user, tmp_stored_location) if continue_after?
  end

  protected

  def find_user
    if session[:attempt_user_id]
      User.find(session[:attempt_user_id])
    else
      user   = User.authenticate_with_ldap(user_params) if Devise.ldap_authentication
      user ||= User.authenticate_with_pam(user_params) if Devise.pam_authentication
      user ||= User.find_for_authentication(email: user_params[:email])
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :otp_attempt, :sign_in_token_attempt)
  end

  def after_sign_in_path_for(resource)
    last_url = stored_location_for(:user)

    if home_paths(resource).include?(last_url)
      root_path
    else
      last_url || root_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    Devise.omniauth_configs.each_value do |config|
      return root_path if config.strategy.redirect_at_sign_in
    end

    super
  end

  def require_no_authentication
    super
    # Delete flash message that isn't entirely useful and may be confusing in
    # most cases because /web doesn't display/clear flash messages.
    flash.delete(:alert) if flash[:alert] == I18n.t('devise.failure.already_authenticated')
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def home_paths(resource)
    paths = [about_path]
    if single_user_mode? && resource.is_a?(User)
      paths << short_account_path(username: resource.account)
    end
    paths
  end

  def continue_after?
    truthy_param?(:continue)
  end
end
