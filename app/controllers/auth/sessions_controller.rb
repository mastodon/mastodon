# frozen_string_literal: true

class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  before_action :configure_sign_in_params, only: [:create]

  def create
    super do |resource|
      remember_me(resource)
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
  end

  def after_sign_in_path_for(_resource)
    last_url = stored_location_for(:user)

    if [about_path].include?(last_url)
      root_path
    else
      last_url || root_path
    end
  end
end
