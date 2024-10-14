# frozen_string_literal: true

class RemoveDuplicateIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :account_aliases, :account_id
    remove_index :account_relationship_severance_events, :account_id
    remove_index :custom_filter_statuses, :status_id
    remove_index :webauthn_credentials, :user_id
  end
end
