# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  include Auth::CaptchaConcern

  layout 'auth'

  before_action :set_body_classes
  before_action :set_pack
  before_action :set_confirmation_user!, only: [:show, :confirm_captcha]
  before_action :redirect_confirmed_user, if: :signed_in_confirmed_user?

  before_action :extend_csp_for_captcha!, only: [:show, :confirm_captcha]
  before_action :require_captcha_if_needed!, only: [:show]

  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!

  def show
    old_session_values = session.to_hash
    reset_session
    session.update old_session_values.except('session_id')

    super
  end

  def new
    super

    resource.email = current_user.unconfirmed_email || current_user.email if user_signed_in?
  end

  def confirm_captcha
    check_captcha! do |message|
      flash.now[:alert] = message
      render :captcha
      return
    end

    show
  end

  def redirect_to_app?
    truthy_param?(:redirect_to_app)
  end

  helper_method :redirect_to_app?

  private

  def require_captcha_if_needed!
    render :captcha if captcha_required?
  end

  def set_confirmation_user!
    # We need to reimplement looking up the user because
    # Devise::ConfirmationsController#show looks up and confirms in one
    # step.
    confirmation_token = params[:confirmation_token]
    return if confirmation_token.nil?

    @confirmation_user = User.find_first_by_auth_conditions(confirmation_token: confirmation_token)
  end

  def captcha_user_bypass?
    @confirmation_user.nil? || @confirmation_user.confirmed?
  end

  def set_pack
    use_pack 'auth'
  end

  def redirect_confirmed_user
    redirect_to(current_user.approved? ? root_path : edit_user_registration_path)
  end

  def signed_in_confirmed_user?
    user_signed_in? && current_user.confirmed? && current_user.unconfirmed_email.blank?
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def after_resending_confirmation_instructions_path_for(_resource_name)
    if user_signed_in?
      if current_user.confirmed? && current_user.approved?
        edit_user_registration_path
      else
        auth_setup_path
      end
    else
      new_user_session_path
    end
  end

  def after_confirmation_path_for(_resource_name, user)
    if user.created_by_application && redirect_to_app?
      user.created_by_application.confirmation_redirect_uri
    elsif user_signed_in?
      web_url('start')
    else
      new_user_session_path
    end
  end
end
