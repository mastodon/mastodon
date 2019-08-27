class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def keycloakopenid

    Rails.logger.debug(request.env["omniauth.auth"])
    @user = User.find_for_oauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Rails.logger.debug()     
      sign_in_and_redirect @user, event: :authentication
    else
      # user has been created but not saved yet, edit profile and sign up
      session["devise.keycloakopenid_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url

    end
  end

  def failure
    redirect_to root_path
  end
end