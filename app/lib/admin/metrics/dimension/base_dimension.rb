# frozen_string_literal: true

class Admin::Metrics::Dimension::BaseDimension
  def initialize(start_at, end_at, limit, params)
    @start_at = start_at&.to_datetime
    @end_at   = end_at&.to_datetime
    @limit    = limit&.to_i
    @params   = params
  end

  def key
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
    (@start_at..@end_at)
  end

  def params
    raise NotImplementedError
  end
end
