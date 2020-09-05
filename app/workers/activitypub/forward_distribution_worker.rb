# frozen_string_literal: true

class ActivityPub::ForwardDistributionWorker < ActivityPub::DistributionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'push'

  def perform(conversation_id, json)
    conversation = Conversation.find(conversation_id)

    @status  = conversation.parent_status
    @account = conversation.parent_account
    @json    = json

    return if @status.nil? || @account.nil?

    deliver_to_inboxes!
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def payload
    @json
  end
end
