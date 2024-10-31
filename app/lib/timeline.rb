# frozen_string_literal: true

module Timeline
  extend Redisable

  module_function

  def subscribed?(timeline)
    redis.exists?("subscribed:#{timeline}")
  end
end
