# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    data = request.respond_to?(:get_header) ? request.get_header("omniauth.auth") : request.env["omniauth.auth"]
    session["devise.facebook_data"] = data["extra"]["user_hash"]
    render json: data
  end

  def sign_in_facebook
    user = User.to_adapter.find_first(email: 'user@test.com')
    user.remember_me = true
    sign_in user
    render (Devise::Test.rails5? ? :body : :text) => ""
  end
end
