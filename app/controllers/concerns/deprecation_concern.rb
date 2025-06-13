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
      end
    end
  end
end
