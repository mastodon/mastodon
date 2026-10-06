# frozen_string_literal: true

module ActivityPub::OpenTelemetry
  def self.decorate_current_span(payload:, namespace: 'activity')
    decorate_span(span: OpenTelemetry::Trace.current_span, payload:, namespace:)
  end

  def self.decorate_span(span:, payload:, namespace: 'activity')
    return unless span.recording?
    return unless payload.is_a?(Hash)

    id = payload['id']
    type = payload['type']

    span.set_attribute("activitypub.#{namespace}.id", id) if id.present?
    span.set_attribute("activitypub.#{namespace}.type", type) if type.present?
  end
end
