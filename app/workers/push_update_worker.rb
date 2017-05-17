# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(account_id, status_id)
    account = Account.find(account_id)
    status  = Status.find(status_id)
    Redis.current.publish(
      "timeline:#{account.id}",
      InlineRenderer.render(
        Event.new(status, (Time.now.to_f * 1000.0).to_i),
        account,
        'streaming/update'
      )
    )
  rescue ActiveRecord::RecordNotFound
    true
  end
end
