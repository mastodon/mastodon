# frozen_string_literal: true

class AddNotNullToAccountConversationAccountColumn < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :account_conversations, 'account_id IS NOT NULL', name: 'account_conversations_account_id_null', validate: false
  end
end
