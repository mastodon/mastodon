class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  def create
    super do |resource|
      remember_me(resource)
    end
  end

  protected

  def after_sign_in_path_for(_resource)
    last_url = stored_location_for(:user)

    if [about_path].include?(last_url)
      root_path
    else
      last_url || root_path
    end
  end
end
