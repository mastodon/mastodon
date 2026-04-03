# frozen_string_literal: true

module Account::MutingConversations
  extend ActiveSupport::Concern

  included do
    has_many :conversation_mutes, dependent: :destroy
  end

  def mute_conversation!(conversation)
    conversation_mutes.find_or_create_by!(conversation:)
  end

  def unmute_conversation!(conversation)
    conversation_mutes
      .find_by(conversation:)
      &.destroy!
  end

  def muting_conversation?(conversation)
    conversation_mutes.exists?(conversation:)
  end
end
