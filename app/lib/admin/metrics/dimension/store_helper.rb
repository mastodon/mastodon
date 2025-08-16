# frozen_string_literal: true

module Admin::Metrics::Dimension::StoreHelper
  include Redisable

  protected

  def store_name
    return 'Valkey' if valkey_version
    return 'Dragonfly' if dragonfly_version

    'Redis'
  end

  def store_version
    valkey_version || dragonfly_version || redis_version
  end

  def store_size
    redis_info['used_memory']
  end

  private

  def redis_info
    @redis_info ||= redis.info
  end

  def redis_version
    redis_info['redis_version']
  end

  def valkey_version
    redis_info['valkey_version']
  end

  def dragonfly_version
    redis_info['dragonfly_version']
  end
end
