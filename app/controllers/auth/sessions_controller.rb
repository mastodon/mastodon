# frozen_string_literal: true

class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  skip_before_action :require_no_authentication, only: [:create]
  skip_before_action :require_functional!

  prepend_before_action :authenticate_with_two_factor, if: :two_factor_enabled?, only: [:create]

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
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    else
      user   = User.authenticate_with_ldap(user_params) if Devise.ldap_authentication
      user ||= User.authenticate_with_pam(user_params) if Devise.pam_authentication
      user ||= User.find_for_authentication(email: user_params[:email])
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :otp_attempt)
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

  def two_factor_enabled?
    find_user&.otp_required_for_login?
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
      user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  rescue OpenSSL::Cipher::CipherError
    false
  end

  def authenticate_with_two_factor
    user = self.resource = find_user

    if user_params[:otp_attempt].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(user)
    elsif user.present? && (user.encrypted_password.blank? || user.valid_password?(user_params[:password]))
      # If encrypted_password is blank, we got the user from LDAP or PAM,
      # so credentials are already valid

      prompt_for_two_factor(user)
    end
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      session.delete(:otp_user_id)
      remember_me(user)
      sign_in(user)
    else
      flash.now[:alert] = I18n.t('users.invalid_otp_token')
      prompt_for_two_factor(user)
    end
  end

  def prompt_for_two_factor(user)
    session[:otp_user_id] = user.id
    @body_classes = 'lighter'
    render :two_factor
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
