class Auth::SessionsController < Devise::SessionsController
  include Devise::Controllers::Rememberable

  layout 'auth'

  def create
    super do |resource|
      remember_me(resource)
    end
  end
end
