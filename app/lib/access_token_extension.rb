# frozen_string_literal: true

module AccessTokenExtension
  extend ActiveSupport::Concern

  included do
    after_commit :push_to_streaming_api
  end

  def revoke(clock = Time)
    update(revoked_at: clock.now.utc)
  end

  def push_to_streaming_api
    Redis.current.publish("timeline:access_token:#{id}", Oj.dump(event: :kill)) if revoked? || destroyed?
  end
end
