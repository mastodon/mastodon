# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(account_ids, status_id)
    status = Status.find(status_id)
    Account.where(id: account_ids).each do |account|
      message = InlineRenderer.render(status, account, 'api/v1/statuses/show')

      Redis.current.publish("timeline:#{account.id}", Oj.dump(event: :update, payload: message, queued_at: (Time.now.to_f * 1000.0).to_i))
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
