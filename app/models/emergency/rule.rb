# frozen_string_literal: true

# == Schema Information
#
# Table name: emergency_rules
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  duration   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Emergency::Rule < ApplicationRecord
  include Redisable

  has_many :triggers, class_name: 'Emergency::Trigger', foreign_key: 'emergency_rule_id', inverse_of: :emergency_rule, dependent: :destroy
  has_many :rate_limit_actions, class_name: 'Emergency::RateLimitAction', foreign_key: 'emergency_rule_id', inverse_of: :emergency_rule, dependent: :destroy

  validates :name, presence: true

  def active?
    with_redis { |redis| redis.get(redis_key).present? }
  end

  def deactivate!
    with_redis { |redis| redis.del(redis_key) }
  end

  def triggered_at
    raw = with_redis { |redis| redis.get(redis_key) }
    Time.at(raw.to_i).utc if raw.present?
  end

  def trigger!(event_start)
    Emergency::Rule.redis_set_if_lower!(redis_key, event_start.to_i, ex: duration)
  end

  class << self
    include Redisable

    LUA_SET_IF_LOWER = <<~LUA
      local key, new_value, expiration = KEYS[1], ARGV[1], ARGV[2]
      local value = redis.call('GET', key)
      if (not value) or tonumber(value) > tonumber(new_value) then
        if expiration then
          return redis.call('SET', key, new_value, 'EX', expiration)
        else
          return redis.call('SET', key, new_value)
        end
      else
        if expiration then
          return redis.call('EXPIRE', key, expiration)
        else
          return redis.call('PERSIST', key)
        end
      end
    LUA

    def redis_set_if_lower!(key, value, ex: nil) # rubocop:disable Naming/MethodParameterName
      with_redis do |redis|
        if @lua_set_if_lower_sha.nil?
          raw_conn = redis.respond_to?(:redis) ? redis.redis : redis
          @lua_set_if_lower_sha = raw_conn.script(:load, LUA_SET_IF_LOWER)
        end

        args = [value]
        args << ex if ex.present?
        redis.evalsha(@lua_set_if_lower_sha, [key], args)
      rescue Redis::CommandError => e
        raise unless e.message.start_with?('NOSCRIPT')

        @lua_set_if_lower_sha = nil
        retry
      end
    end

    def triggered_at(ids)
      return [] if ids.empty?

      with_redis do |redis|
        redis.mget(ids.map { |rule_id| "emergency_rules:triggered_at:#{rule_id}" }).map { |raw| Time.at(raw.to_i).utc if raw.present? }
      end
    end

    def any_active?
      triggered_at(pluck(:id)).any?
    end
  end

  private

  def redis_key
    "emergency_rules:triggered_at:#{id}"
  end
end
