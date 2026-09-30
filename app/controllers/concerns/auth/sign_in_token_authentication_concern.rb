# frozen_string_literal: true

module Auth::SignInTokenAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_sign_in_token, if: :sign_in_token_required?, only: [:create]
  end

  def sign_in_token_required?
    find_user&.suspicious_inactive_sign_in?
  end

  def authenticate_with_sign_in_token
    user = self.resource = find_user

    if user_params[:sign_in_token_attempt].present? && session[:attempt_user_id]
      authenticate_with_sign_in_token_attempt(user)
    elsif user.present? && user.valid_password?(user_params[:password])
      prompt_for_sign_in_token(user)
    end
  end

  def authenticate_with_sign_in_token_attempt(user)
    if user.valid_sign_in_token?(user_params[:sign_in_token_attempt])
      clear_attempt_from_session
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

    register_attempt_in_session(user)
    render :sign_in_token
  end
end
