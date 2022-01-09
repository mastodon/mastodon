# frozen_string_literal: true

class Api::V1::MarkersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, except: [:index]

  before_action :require_user!

  def index
    @markers = current_user.markers.where(timeline: Array(params[:timeline])).index_by(&:timeline)
    render json: serialize_map(@markers)
  end

  def create
    Marker.transaction do
      @markers = {}

      resource_params.each_pair do |timeline, timeline_params|
        @markers[timeline] = current_user.markers.find_or_initialize_by(timeline: timeline)
        @markers[timeline].update!(timeline_params)
      end
    end

    render json: serialize_map(@markers)
  rescue ActiveRecord::StaleObjectError
    render json: { error: 'Conflict during update, please try again' }, status: 409
  end

  private

  def serialize_map(map)
    serialized = {}

    map.each_pair do |key, value|
      serialized[key] = ActiveModelSerializers::SerializableResource.new(value, serializer: REST::MarkerSerializer).as_json
    end

    Oj.dump(serialized)
  end

  def resource_params
    params.slice(*Marker::TIMELINES).permit(*Marker::TIMELINES.map { |timeline| { timeline.to_sym => [:last_read_id] } })
  end
end
