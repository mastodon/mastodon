# frozen_string_literal: true

class AddNotNullToAccountConversationConversationColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :account_conversations, 'conversation_id IS NOT NULL', name: 'account_conversations_conversation_id_null', validate: false
  end
end
