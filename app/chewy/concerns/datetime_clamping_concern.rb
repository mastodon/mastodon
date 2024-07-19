# frozen_string_literal: true

module DatetimeClampingConcern
  extend ActiveSupport::Concern

  MIN_ISO8601_DATETIME = '0000-01-01T00:00:00Z'.to_datetime.freeze
  MAX_ISO8601_DATETIME = '9999-12-31T23:59:59Z'.to_datetime.freeze

  class_methods do
    def clamp_date(datetime)
      datetime.clamp(MIN_ISO8601_DATETIME, MAX_ISO8601_DATETIME)
    end
  end
end
