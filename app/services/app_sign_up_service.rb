# frozen_string_literal: true

class AppSignUpService < BaseService
  def call(app, params)
    return unless allowed_registrations?

    user_params           = params.slice(:email, :password, :agreement, :locale)
    account_params        = params.slice(:username)
    invite_request_params = { text: params[:reason] }
    user                  = User.create!(user_params.merge(created_by_application: app, password_confirmation: user_params[:password], account_attributes: account_params, invite_request_attributes: invite_request_params))

    Doorkeeper::AccessToken.create!(application: app,
                                    resource_owner_id: user.id,
                                    scopes: app.scopes,
                                    expires_in: Doorkeeper.configuration.access_token_expires_in,
                                    use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?)
  end

  private

  def allowed_registrations?
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end
end
