# frozen_string_literal: true

module Auth::SignInTokenAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_sign_in_token, if: :sign_in_token_required?, only: [:create]
  end

  def sign_in_token_required?
    # Password verification is skipped at this stage, it will happen later if necessary
    find_user(allow_unverified: true)&.suspicious_inactive_sign_in?
  end

  def authenticate_with_sign_in_token
    user = ensure_first_authentication_step(allow_external: false) { |user| prompt_for_sign_in_token(user) }
    return if user.nil?

    if params.key?(:sign_in_token_resend)
      prompt_for_sign_in_token(user, resend: true)
    elsif user_params[:sign_in_token_attempt].present?
      authenticate_with_sign_in_token_attempt(user)
    end
  end

  def authenticate_with_sign_in_token_attempt(user)
    if check_second_factor_rate_limits(user)
      flash.now[:alert] = I18n.t('users.rate_limited')
      return prompt_for_sign_in_token(user)
    end

    if user.valid_sign_in_token?(user_params[:sign_in_token_attempt])
      user.clear_sign_in_token!
      on_authentication_success(user, :sign_in_token)
    else
      on_authentication_failure(user, :sign_in_token, :invalid_sign_in_token)
      flash.now[:alert] = I18n.t('users.invalid_sign_in_token')
      prompt_for_sign_in_token(user)
    end
  end

  def prompt_for_sign_in_token(user, resend: false)
    if resend || user.sign_in_token_expired?
      user.generate_sign_in_token && user.save
      UserMailer.sign_in_token(user, request.remote_ip, request.user_agent, Time.now.utc.to_s).deliver_later!
    end

    register_attempt_in_session(user)
    render :sign_in_token
  end
end
