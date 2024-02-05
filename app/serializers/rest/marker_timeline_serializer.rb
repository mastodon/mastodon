# frozen_string_literal: true

class REST::MarkerTimelineSerializer < ActiveModel::Serializer
  Marker::TIMELINES.each do |timeline|
    has_one timeline.to_sym,
            if: -> { timeline_present?(timeline) },
            serializer: REST::MarkerSerializer
  end

  delegate :timeline_present?, to: :object
end
