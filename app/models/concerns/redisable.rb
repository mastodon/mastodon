# frozen_string_literal: true

module Redisable
  extend ActiveSupport::Concern

  private

  def redis
    Thread.current[:redis] ||= RedisConfiguration.new.connection
  end
end
