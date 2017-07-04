class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.provides_callback_for(provider)
    _provider = provider.to_s.chomp "_oauth2"
    define_method provider do
      @user = User.find_for_oauth(env["omniauth.auth"], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: _provider.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  [:ldap, :cas].each do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      root_path
    else
      finish_signup_path
    end
  end
end
