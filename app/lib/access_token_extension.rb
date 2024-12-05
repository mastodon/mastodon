# frozen_string_literal: true

module AccessTokenExtension
  extend ActiveSupport::Concern

  included do
    include Redisable

    has_many :web_push_subscriptions, class_name: 'Web::PushSubscription', inverse_of: :access_token

    after_commit :push_to_streaming_api

    scope :expired, -> { where.not(expires_in: nil).where('created_at + MAKE_INTERVAL(secs => expires_in) < NOW()') }
    scope :not_revoked, -> { where(revoked_at: nil) }
    scope :revoked, -> { where.not(revoked_at: nil).where(revoked_at: ...Time.now.utc) }
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
