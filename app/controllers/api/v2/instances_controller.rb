# frozen_string_literal: true

class Api::V2::InstancesController < Api::V1::InstancesController
  def show
    expires_in 3.minutes, public: true
    render json: InstancePresenter.new, serializer: REST::InstanceSerializer, root: 'instance'
  end
end
