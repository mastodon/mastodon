# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def qiita
    auth_hash = request.env['omniauth.auth']

    if current_user
      authorization = QiitaAuthorization.find_or_initialize_by(uid: auth_hash[:uid]) do |qiita_authorization|
        authorization.user = current_user
      end

      if authorization.save
        flash[:notice] = I18n.t('omniauth_callbacks.success')
      else
        flash[:alert] = I18n.t('omniauth_callbacks.failure')
      end
        redirect_to settings_qiita_authorizations_path
    else
      if authorization = QiitaAuthorization.find_by(uid: auth_hash[:uid])
        sign_in(authorization.user)
        redirect_to web_path
      else
        store_omniauth_auth
        redirect_to new_user_oauth_registration_path
      end
    end
  end

  private

  def store_omniauth_auth
    session[:devise_omniauth_auth] = request.env['omniauth.auth']
  end
end
