# frozen_string_literal: true

class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  skip_before_action :authenticate_resource_owner!

  before_action :set_locale
  before_action :store_current_location
  before_action :authenticate_resource_owner!

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def set_locale
    I18n.locale = current_user.try(:locale) || I18n.default_locale
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end
end
