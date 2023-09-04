# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker
  include Redisable

  def perform(account_id, status_id, timeline_id = nil, options = {})
    @status      = Status.find(status_id)
    @account_id  = account_id
    @timeline_id = timeline_id || "timeline:#{account_id}"
    @options     = options.symbolize_keys

    render_payload!
    publish!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def render_payload!
    @payload = StatusCacheHydrator.new(@status).hydrate(@account_id)
  end

  def message
    Oj.dump(
      event: update? ? :'status.update' : :update,
      payload: @payload,
      queued_at: (Time.now.to_f * 1000.0).to_i
    )
  end

  def publish!
    redis.publish(@timeline_id, message)
  end

  def update?
    @options[:update]
  end
end
