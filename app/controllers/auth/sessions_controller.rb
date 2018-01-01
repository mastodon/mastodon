# frozen_string_literal: true

class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  skip_before_action :require_no_authentication, only: [:create]
  skip_before_action :check_suspension, only: [:destroy]
  prepend_before_action :authenticate_with_two_factor, if: :two_factor_enabled?, only: [:create]
  before_action :set_alternative, only: [:new]
  before_action :set_instance_presenter, only: [:new]

  def create
    super do |resource|
      remember_me(resource)
      flash.delete(:notice)
    end
  end

  def destroy
    super
    flash.delete(:notice)
  end

  protected

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    elsif user_params[:email]
      User.find_for_authentication(email: user_params[:email])
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

  def two_factor_enabled?
    find_user.try(:otp_required_for_login?)
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
      user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  rescue OpenSSL::Cipher::CipherError => _error
    false
  end

  def authenticate_with_two_factor
    user = self.resource = find_user

    if user_params[:otp_attempt].present? && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(user)
    elsif user&.valid_password?(user_params[:password])
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
    render :two_factor
  end

  private

  def set_alternative
    last_url = stored_location_for(:user)
    return if last_url.nil?

    parsed_last_url = Addressable::URI.parse(last_url)
    params = Rails.application.routes.recognize_path(parsed_last_url.path)
    return if params[:action] != 'show' || parsed_last_url.query_values['web'].present?

    case params[:controller]
    when 'authorize_follows'
      acct = parsed_last_url.query_values['acct']
      parsed_acct = Addressable::URI.parse(acct)
      uri = parsed_acct

      unless parsed_acct.path && %w(http https).include?(parsed_acct.scheme)
        uri = 'acct:' + uri
      end

      @alternative_href = Addressable::URI.new(
        scheme: 'web+mastodon',
        host: 'follow',
        query_values: { uri: uri }
      )

      @alternative_label = I18n.t('auth.follow_on_another_instance')

    when 'shares'
      @alternative_href = Addressable::URI.new(
        scheme: 'web+mastodon',
        host: 'share',
        query_values: { text: parsed_last_url.query_values['text'] }
      ).to_s

      @alternative_label = I18n.t('auth.share_on_another_instance')
    end
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def home_paths(resource)
    paths = [about_path]
    if single_user_mode? && resource.is_a?(User)
      paths << short_account_path(username: resource.account)
    end
    paths
  end
end
