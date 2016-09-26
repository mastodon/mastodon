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
    root_path
  end
end
