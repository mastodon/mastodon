# frozen_string_literal: true

class Api::V1::MarkersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:index]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, except: [:index]

  before_action :require_user!

  def index
    @markers = current_user_markers
    render json: marker_timeline_presenter, serializer: REST::MarkerTimelineSerializer
  end

  def create
    @markers = create_markers_from_params
    render json: marker_timeline_presenter, serializer: REST::MarkerTimelineSerializer
  rescue ActiveRecord::StaleObjectError
    render json: { error: 'Conflict during update, please try again' }, status: 409
  end

  private

  def marker_timeline_presenter
    MarkerTimelinePresenter.new(@markers)
  end

  def current_user_markers
    with_read_replica do
      current_user.markers.where(timeline: Array(params[:timeline]))
    end
  end

  def create_markers_from_params
    [].tap do |markers|
      Marker.transaction do
        resource_params.each_pair do |timeline, timeline_params|
          current_user.markers.find_or_create_by(timeline: timeline).tap do |marker|
            marker.update!(timeline_params)
            markers << marker
          end
        end
      end
    end
  end

  def resource_params
    params.slice(*Marker::TIMELINES).permit(*Marker::TIMELINES.map { |timeline| { timeline.to_sym => [:last_read_id] } })
  end
end
