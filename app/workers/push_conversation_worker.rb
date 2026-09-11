# frozen_string_literal: true

class PushConversationWorker
  include Sidekiq::Worker
  include Redisable

  def perform(conversation_account_id)
    conversation = AccountConversation.find(conversation_account_id)
    message      = InlineRenderer.render(conversation, conversation.account, :conversation)
    timeline_id  = "timeline:direct:#{conversation.account_id}"

    redis.publish(timeline_id, { event: :conversation, payload: message }.to_json)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
