# frozen_string_literal: true

class AppSignUpService < BaseService
  include RegistrationHelper

  def call(app, remote_ip, params)
    @app       = app
    @remote_ip = remote_ip
    @params    = params

    raise Mastodon::NotPermittedError unless allowed_registration?(remote_ip, invite)

    ApplicationRecord.transaction do
      create_user!
      create_access_token!
    end

    @access_token
  end

  private

  def create_user!
    @user = User.create!(
      user_params.merge(created_by_application: @app, sign_up_ip: @remote_ip, password_confirmation: user_params[:password], account_attributes: account_params, invite_request_attributes: invite_request_params)
    )
  end

  def create_access_token!
    context = Doorkeeper::OAuth::Authorization::Token.build_context(@app, Doorkeeper::OAuth::AUTHORIZATION_CODE, @app.scopes, @user.id)

    @access_token = Doorkeeper::AccessToken.create!(
      application: context.client,
      resource_owner_id: context.resource_owner,
      scopes: context.scopes,
      expires_in: Doorkeeper::OAuth::Authorization::Token.access_token_expires_in(Doorkeeper.config, context),
      use_refresh_token: Doorkeeper::OAuth::Authorization::Token.refresh_token_enabled?(Doorkeeper.config, context)
    )
  end

  def invite
    Invite.find_by(code: @params[:invite_code]) if @params[:invite_code].present?
  end

  def user_params
    @params.slice(:email, :password, :agreement, :locale, :time_zone, :invite_code, :date_of_birth)
  end

  def account_params
    @params.slice(:username)
  end

  def invite_request_params
    { text: @params[:reason] }
  end
end
