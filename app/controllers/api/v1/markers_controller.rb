# frozen_string_literal: true

class Api::V1::MarkersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, except: [:index]

  before_action :require_user!

  def index
    with_read_replica do
      @markers = current_user.markers.where(timeline: Array(params[:timeline])).index_by(&:timeline)
    end

    render json: serialize_map(@markers)
  end

  def create
    @markers = Marker.record(current_user, resource_params)

    render json: serialize_map(@markers)
  rescue ActiveRecord::StaleObjectError
    render json: { error: 'Conflict during update, please try again' }, status: 409
  end

  private

  def serialize_map(map)
    map.transform_values { |value| ActiveModelSerializers::SerializableResource.new(value, serializer: REST::MarkerSerializer) }
  end

  def resource_params
    params.slice(*Marker::TIMELINES).permit(*Marker::TIMELINES.map { |timeline| { timeline.to_sym => [:last_read_id] } })
  end
end
