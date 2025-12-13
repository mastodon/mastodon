# frozen_string_literal: true

class ValidateNotNullToAccountConversationConversationColumn < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM account_conversations
      WHERE conversation_id IS NULL
    SQL

    validate_check_constraint :account_conversations, name: 'account_conversations_conversation_id_null'
    change_column_null :account_conversations, :conversation_id, false
    remove_check_constraint :account_conversations, name: 'account_conversations_conversation_id_null'
  end

  def down
    add_check_constraint :account_conversations, 'conversation_id IS NOT NULL', name: 'account_conversations_conversation_id_null', validate: false
    change_column_null :account_conversations, :conversation_id, true
  end
end
