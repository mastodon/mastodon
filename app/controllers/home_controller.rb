# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @body_classes           = 'app-body'
    @token                  = find_or_create_access_token.token
    @web_settings           = Web::Setting.find_by(user: current_user)&.data || {}
    @admin                  = Account.find_local(Setting.site_contact_username)
    @streaming_api_base_url = Rails.configuration.x.streaming_api_base_url
  end

  private

  def authenticate_user!
    redirect_to(single_user_mode? ? account_path(Account.first) : about_path) unless user_signed_in?
  end

  def find_or_create_access_token
    Doorkeeper::AccessToken.find_or_create_for(Doorkeeper::Application.where(superapp: true).first, current_user.id, 'read write follow', Doorkeeper.configuration.access_token_expires_in, Doorkeeper.configuration.refresh_token_enabled?)
  end
end
