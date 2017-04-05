# frozen_string_literal: true

class PushUpdateWorker
  include Sidekiq::Worker

  def perform(timeline, account_id, status_id)
    account = Account.find(account_id)
    status = Status.find(status_id)
    message = Rabl::Renderer.new(
      'api/v1/statuses/show', 
      status, 
      view_path: 'app/views', 
      format: :json, 
      scope: InlineRablScope.new(account)
    )

    ActionCable.server.broadcast("timeline:#{account_id}", type: 'update', timeline: timeline, message: message.render)
  end
end
