# frozen_string_literal: true

class Admin::Metrics::Dimension::BaseDimension
  CACHE_TTL = 5.minutes.freeze

  def self.with_params?
    false
  end

  attr_reader :loaded

  alias loaded? loaded

  def initialize(start_at, end_at, limit, params)
    @start_at = start_at&.to_datetime
    @end_at   = end_at&.to_datetime
    @limit    = limit&.to_i
    @params   = params
    @loaded   = false
  end

  def key
    raise NotImplementedError
  end

  def cache_key
    ["metrics/dimension/#{key}", @start_at, @end_at, @limit, canonicalized_params].join(';')
  end

  def data
    load
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
      @values = Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) { perform_query }
      @loaded = true
    end

    @values
  end

  def perform_query
    raise NotImplementedError
  end

  def time_period
    (@start_at..@end_at)
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
