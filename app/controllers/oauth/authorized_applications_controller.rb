# frozen_string_literal: true

class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  skip_before_action :authenticate_resource_owner!

  before_action :store_current_location
  before_action :authenticate_resource_owner!
  before_action :require_not_suspended!, only: :destroy
  before_action :set_cache_headers

  before_action :set_last_used_at_by_app, only: :index, unless: -> { request.format == :json }

  skip_before_action :require_functional!

  include Localized

  def destroy
    Web::PushSubscription.unsubscribe_for(params[:id], current_resource_owner)
    Doorkeeper::Application.find_by(id: params[:id])&.close_streaming_sessions(current_resource_owner)
    super
  end

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def require_not_suspended!
    forbidden if current_account.unavailable?
  end

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end

  def set_last_used_at_by_app
    @last_used_at_by_app = current_resource_owner.applications_last_used
  end
end
