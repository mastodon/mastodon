# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(timeline, account_id, status_id)
    account = Account.find(account_id)
    status = Status.find(status_id)
    message = inline_render(account, 'api/v1/statuses/show', status)
    queue_at = (Time.now.to_f * 1000.0).to_i
    ActionCable.server.broadcast("timeline:#{account_id}", type: 'update', timeline: timeline, message: message)
  end
end
