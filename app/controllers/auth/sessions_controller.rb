class Auth::SessionsController < Devise::SessionsController
  layout 'auth'

  def create
    params[:user].merge!(remember_me: 1)
    super
  end
end
