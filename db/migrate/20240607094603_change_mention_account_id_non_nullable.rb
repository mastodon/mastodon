# frozen_string_literal: true

class ChangeMentionAccountIdNonNullable < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :mentions, 'account_id IS NOT NULL', name: 'mentions_account_id_null', validate: false
  end
end
