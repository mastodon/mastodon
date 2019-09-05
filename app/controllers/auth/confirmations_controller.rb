# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'

  before_action :set_body_classes
  before_action :require_unconfirmed!

  skip_before_action :require_functional!

  def new
    super

    resource.email = current_user.unconfirmed_email || current_user.email if user_signed_in?
  end

  private

  def require_unconfirmed!
    redirect_to edit_user_registration_path if user_signed_in? && current_user.confirmed? && current_user.unconfirmed_email.blank?
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
    if user.created_by_application && truthy_param?(:redirect_to_app)
      user.created_by_application.redirect_uri
    else
      super
    end
  end
end
