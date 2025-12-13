# frozen_string_literal: true

module Admin::Metrics::Dimension::StoreHelper
  include Redisable

  private

  def store_name
    return 'Valkey' if redis_info.key?('valkey_version')
    return 'Dragonfly' if redis_info.key?('dragonfly_version')

    'Redis'
  end

  def store_version
    redis_info['valkey_version'] || redis_info['dragonfly_version'] || redis_info['redis_version']
  end

  def store_size
    redis_info['used_memory']
  end

  def redis_info
    @redis_info ||= redis.info
  end
end
