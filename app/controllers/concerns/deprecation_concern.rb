# frozen_string_literal: true

module DeprecationConcern
  extend ActiveSupport::Concern

  class_methods do
    def deprecate_api(date, sunset: nil, **kwargs)
      deprecation_timestamp = "@#{date.to_datetime.to_i}"
      sunset = sunset&.to_date&.httpdate

      before_action(**kwargs) do
        response.headers['Deprecation'] = deprecation_timestamp
        response.headers['Sunset'] = sunset if sunset

        span = OpenTelemetry::Trace.current_span
        next unless span&.recording?

        span.set_attribute('app.endpoint.deprecated', true)
      end
    end
  end
end
