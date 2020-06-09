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

    if user_params[:sign_in_token_attempt].present? && session[:attempt_user_id]
      authenticate_with_sign_in_token_attempt(user)
    elsif user.present? && user.external_or_valid_password?(user_params[:password])
      prompt_for_sign_in_token(user)
    end
  end

  def authenticate_with_sign_in_token_attempt(user)
    if valid_sign_in_token_attempt?(user)
      session.delete(:attempt_user_id)
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

    session[:attempt_user_id] = user.id
    use_pack 'auth'
    @body_classes = 'lighter'
    render :sign_in_token
  end
end
