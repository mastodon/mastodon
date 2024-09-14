# frozen_string_literal: true

class AddUnreadToAccountConversations < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :account_conversations,
        :unread,
        :boolean,
        null: false,
        default: false
      )
    end
  end

  def down
    remove_column :account_conversations, :unread, :boolean
  end
end
