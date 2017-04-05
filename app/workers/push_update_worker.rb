# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(timeline, account_id, status_id)
    account = Account.find(account_id)
    status = Status.find(status_id)
    message = inline_render(account, 'api/v1/statuses/show', status)

    broadcast(account_id, type: 'update', timeline: timeline, message: message)
  end
end
