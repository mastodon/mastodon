# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  def self.provides_callback_for(provider)
    define_method provider do
      @provider = provider
      @user = User.find_for_oauth(request.env['omniauth.auth'], current_user)

      if @user.persisted?
        record_login_activity
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: label_for_provider) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end

  Devise.omniauth_configs.each_key do |provider|
    provides_callback_for provider
  end

  def after_sign_in_path_for(resource)
    if resource.email_present?
      stored_location_for(resource) || root_path
    else
      auth_setup_path(missing_email: '1')
    end
  end

  private

  def record_login_activity
    LoginActivity.create(
      user: @user,
      success: true,
      authentication_method: :omniauth,
      provider: @provider,
      ip: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  def label_for_provider
    provider_display_name || configured_provider_name
  end

  def provider_display_name
    Devise.omniauth_configs[@provider]&.strategy&.display_name.presence
  end

  def configured_provider_name
    I18n.t("auth.providers.#{@provider}", default: @provider.to_s.chomp('_oauth2').capitalize)
  end
end
