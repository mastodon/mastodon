# frozen_string_literal: true

class Api::V1::InstancesController < Api::BaseController
  respond_to :json

  skip_before_action :set_cache_headers
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  def show
    expires_in 3.minutes, public: true
    render_with_cache json: {}, serializer: REST::InstanceSerializer, root: 'instance'
  end
end
