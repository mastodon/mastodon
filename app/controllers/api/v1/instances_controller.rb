# frozen_string_literal: true

class Api::V1::InstancesController < Api::BaseController
  respond_to :json

  def show
    render json: {}, serializer: REST::InstanceSerializer
  end
end
