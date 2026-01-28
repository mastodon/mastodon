# frozen_string_literal: true

class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  skip_before_action :authenticate_resource_owner!

  before_action :store_current_location
  before_action :authenticate_resource_owner!

  layout 'modal'

  content_security_policy do |p|
    p.form_action(false)
  end

  include Localized

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def can_authorize_response?
    !truthy_param?('force_login') && super
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end
end
