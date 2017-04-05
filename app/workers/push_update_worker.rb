# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(timeline, account_id, status_id)
    account = Account.find(account_id)
    status  = Status.find(status_id)
    
    message = Rabl::Renderer.new(
      'api/v1/statuses/show', 
      status, 
      view_path: 'app/views', 
      format: :json, 
      scope: InlineRablScope.new(account)
    )

    Redis.current.publish("timeline:#{timeline_id}", Oj.dump({ event: :update, payload: message, queued_at: (Time.now.to_f * 1000.0).to_i }))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
