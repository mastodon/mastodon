# frozen_string_literal: true

module SignInTokenAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_sign_in_token, if: :sign_in_token_required?, only: [:create]
  end

  def sign_in_token_required?
    find_user&.suspicious_sign_in?(request.remote_ip)
  end

  def valid_sign_in_token_attempt?(user)
    Devise.secure_compare(user.sign_in_token, user_params[:sign_in_token_attempt])
  end

  def authenticate_with_sign_in_token
    user = self.resource = find_user

    if user.present? && session[:attempt_user_id].present? && session[:attempt_user_updated_at] != user.updated_at.to_s
      restart_session
    elsif user_params.key?(:sign_in_token_attempt) && session[:attempt_user_id]
      authenticate_with_sign_in_token_attempt(user)
    elsif user.present? && user.external_or_valid_password?(user_params[:password])
      prompt_for_sign_in_token(user)
    end
  end

  def authenticate_with_sign_in_token_attempt(user)
    if valid_sign_in_token_attempt?(user)
      on_authentication_success(user, :sign_in_token)
    else
      on_authentication_failure(user, :sign_in_token, :invalid_sign_in_token)
      flash.now[:alert] = I18n.t('users.invalid_sign_in_token')
      prompt_for_sign_in_token(user)
    end
  end

  def prompt_for_sign_in_token(user)
    if user.sign_in_token_expired?
      user.generate_sign_in_token && user.save
      UserMailer.sign_in_token(user, request.remote_ip, request.user_agent, Time.now.utc.to_s).deliver_later!
    end

    set_attempt_session(user)

    @body_classes = 'lighter'

    set_locale { render :sign_in_token }
  end
end
