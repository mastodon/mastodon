# frozen_string_literal: true

class Api::V1::InstancesController < Api::BaseController
  respond_to :json

  def show
    render_cached_json('api:v1:instances', expires_in: 5.minutes) do
      ActiveModelSerializers::SerializableResource.new({}, serializer: REST::InstanceSerializer)
    end
  end
end
