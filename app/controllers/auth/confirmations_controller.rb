# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'

  before_action :set_body_classes
  before_action :set_user, only: [:finish_signup]

  def finish_signup
    return unless request.patch? && params[:user]

    if @user.update(user_params)
      @user.skip_reconfirmation!
      bypass_sign_in(@user)
      redirect_to root_path, notice: I18n.t('devise.confirmations.send_instructions')
    else
      @show_errors = true
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def user_params
    params.require(:user).permit(:email)
  end

  def after_confirmation_path_for(_resource_name, user)
    if user.created_by_application && truthy_param?(:redirect_to_app)
      user.created_by_application.redirect_uri
    else
      super
    end
  end
end
