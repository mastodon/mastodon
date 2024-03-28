# frozen_string_literal: true

class MarkerTimelinePresenter
  include ActiveModel::Model

  alias read_attribute_for_serialization send

  attr_reader :markers

  def initialize(markers)
    @markers = markers
  end

  Marker::TIMELINES.each do |timeline|
    define_method timeline.to_sym do
      markers.find { |marker| marker.timeline == timeline }
    end
  end

  def timeline_present?(value)
    markers.map(&:timeline).include?(value)
  end
end
