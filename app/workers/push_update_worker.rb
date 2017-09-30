# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(account_id, status_id)
    account = Account.find(account_id)
    status  = Status.find(status_id)
    message = InlineRenderer.render(status, account, :status)

    Redis.current.publish("timeline:#{account.id}", Oj.dump(event: :update, payload: message, queued_at: (Time.now.to_f * 1000.0).to_i))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
