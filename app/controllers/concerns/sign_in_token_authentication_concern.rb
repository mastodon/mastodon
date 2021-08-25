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
    if user_params[:email].present?
      user = self.resource = find_user_from_params
      prompt_for_sign_in_token(user) if user&.external_or_valid_password?(user_params[:password])
    elsif session[:attempt_user_id]
      user = self.resource = User.find_by(id: session[:attempt_user_id])
      return if user.nil?

      if session[:attempt_user_updated_at] != user.updated_at.to_s
        restart_session
      elsif user_params.key?(:sign_in_token_attempt)
        authenticate_with_sign_in_token_attempt(user)
      end
    end
  end

  def authenticate_with_sign_in_token_attempt(user)
    if valid_sign_in_token_attempt?(user)
      clear_attempt_from_session
      remember_me(user)
      sign_in(user)
    else
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
