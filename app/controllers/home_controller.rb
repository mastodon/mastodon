# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @body_classes           = 'app-body'
    @token                  = current_session.token
    @web_settings           = Web::Setting.find_by(user: current_user)&.data || {}
    @admin                  = Account.find_local(Setting.site_contact_username)
    @streaming_api_base_url = Rails.configuration.x.streaming_api_base_url
  end

  private

  def authenticate_user!
    redirect_to(single_user_mode? ? account_path(Account.first) : about_path) unless user_signed_in?
  end
end
