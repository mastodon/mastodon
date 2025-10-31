# frozen_string_literal: true

class Admin::Metrics::Measure::BaseMeasure
  CACHE_TTL = 5.minutes.freeze

  def self.with_params?
    false
  end

  attr_reader :loaded

  alias loaded? loaded

  def initialize(start_at, end_at, params)
    @start_at = start_at&.to_datetime
    @end_at   = end_at&.to_datetime
    @params   = params
    @loaded   = false
  end

  def cache_key
    ["metrics/measure/#{key}", @start_at, @end_at, canonicalized_params].join(';')
  end

  def key
    raise NotImplementedError
  end

  def unit
    nil
  end

  def total_in_time_range?
    true
  end

  def total
    load[:total]
  end

  def previous_total
    load[:previous_total]
  end

  def data
    load[:data]
  end

  def self.model_name
    self.class.name
  end

  def read_attribute_for_serialization(key)
    send(key) if respond_to?(key)
  end

  protected

  def load
    unless loaded?
      @values = Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { perform_queries }.with_indifferent_access
      @loaded = true
    end

    @values
  end

  def perform_queries
    {
      total: perform_total_query,
      previous_total: perform_previous_total_query,
      data: perform_data_query,
    }
  end

  def perform_total_query
    raise NotImplementedError
  end

  def perform_previous_total_query
    raise NotImplementedError
  end

  def perform_data_query
    raise NotImplementedError
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end

  def length_of_period
    @length_of_period ||= @end_at - @start_at
  end

  def params
    {}
  end

  def canonicalized_params
    params.to_h.to_a.sort_by { |k, _v| k.to_s }.map { |k, v| "#{k}=#{v}" }.join(';')
  end

  def earliest_status_id
    snowflake_id(@start_at.beginning_of_day)
  end

  def latest_status_id
    snowflake_id(@end_at.end_of_day)
  end

  def snowflake_id(datetime)
    Mastodon::Snowflake.id_at(datetime, with_random: false)
  end
end
