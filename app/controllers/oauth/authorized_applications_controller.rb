# frozen_string_literal: true

class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  skip_before_action :authenticate_resource_owner!

  before_action :store_current_location
  before_action :authenticate_resource_owner!
  before_action :set_pack
  before_action :set_body_classes

  skip_before_action :require_functional!

  include Localized

  def destroy
    Web::PushSubscription.unsubscribe_for(params[:id], current_resource_owner)
    super
  end

  private

  def set_body_classes
    @body_classes = 'admin'
  end

  def store_current_location
    store_location_for(:user, request.url)
  end

  def set_pack
    use_pack 'settings'
  end
end
