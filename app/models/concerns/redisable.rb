# frozen_string_literal: true

module Redisable
  extend ActiveSupport::Concern

  private

  def redis
    Redis.current
  end
end
