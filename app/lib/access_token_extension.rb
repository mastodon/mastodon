# frozen_string_literal: true

module AccessTokenExtension
  extend ActiveSupport::Concern

  included do
    include Redisable

    after_commit :push_to_streaming_api
  end

  def revoke(clock = Time)
    update(revoked_at: clock.now.utc)
  end

  def update_last_used(request, clock = Time)
    update(last_used_at: clock.now.utc, last_used_ip: request.remote_ip)
  end

  def push_to_streaming_api
    redis.publish("timeline:access_token:#{id}", Oj.dump(event: :kill)) if revoked? || destroyed?
  end
end
