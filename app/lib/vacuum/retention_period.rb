# frozen_string_literal: true

module Vacuum
  # Vacuumer initialized with retention period duration
  class RetentionPeriod
    # @param retention_period [ActiveSupport::Duration] the retention duration
    def initialize(retention_period)
      @retention_period = retention_period
    end

    def perform
      raise "Tried to run perform on base klass: #{self.class.name}"
    end
  end
end
