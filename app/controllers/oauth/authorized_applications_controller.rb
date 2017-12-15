# frozen_string_literal: true

class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  skip_before_action :authenticate_resource_owner!

  before_action :store_current_location
  before_action :authenticate_resource_owner!
  before_action :set_pack

  include Localized

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def set_pack
    use_pack 'settings'
  end
end
