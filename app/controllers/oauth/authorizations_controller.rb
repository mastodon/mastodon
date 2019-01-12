# frozen_string_literal: true

class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  skip_before_action :authenticate_resource_owner!

  before_action :store_current_location
  before_action :authenticate_resource_owner!

  include Localized

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def render_success
    if skip_authorization? || (matching_token? && !truthy_param?('force_login'))
      redirect_or_render authorize_response
    elsif Doorkeeper.configuration.api_only
      render json: pre_auth
    else
      render :new
    end
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end
end
