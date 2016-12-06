# frozen_string_literal: true

class Auth::RegistrationsController < Devise::RegistrationsController
  layout 'auth'

  before_action :check_single_user_mode
  before_action :configure_sign_up_params, only: [:create]

  protected

  def build_resource(hash = nil)
    super(hash)
    resource.build_account if resource.account.nil?
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit({ account_attributes: [:username] }, :email, :password, :password_confirmation)
    end
  end

  def after_sign_up_path_for(_resource)
    new_user_session_path
  end

  def check_single_user_mode
    redirect_to root_path if Rails.configuration.x.single_user_mode
  end
end
