# frozen_string_literal: true

class Admin::Metrics::Measure::BaseMeasure
  def initialize(start_at, end_at)
    @start_at = start_at&.to_datetime
    @end_at   = end_at&.to_datetime
  end

  def key
    raise NotImplementedError
  end

  def total
    raise NotImplementedError
  end

  def previous_total
    raise NotImplementedError
  end

  def data
    raise NotImplementedError
  end

  def self.model_name
    self.class.name
  end

  def read_attribute_for_serialization(key)
    send(key) if respond_to?(key)
  end

  protected

  def time_period
    (@start_at...@end_at)
  end

  def previous_time_period
    ((@start_at - length_of_period)...(@end_at - length_of_period))
  end

  def length_of_period
    @length_of_period ||= @end_at - @start_at
  end
end
