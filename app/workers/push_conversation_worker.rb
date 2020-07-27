# frozen_string_literal: true

class PushConversationWorker
  include Sidekiq::Worker
  include Redisable

  def perform(conversation_account_id)
    conversation = AccountConversation.find(conversation_account_id)
    message      = InlineRenderer.render(conversation, conversation.account, :conversation)
    timeline_id  = "timeline:direct:#{conversation.account_id}"

    redis.publish(timeline_id, Oj.dump(event: :conversation, payload: message, queued_at: (Time.now.to_f * 1000.0).to_i))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
