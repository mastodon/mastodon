# frozen_string_literal: true

class BackfillRelaysAccountId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class Relay < ApplicationRecord; end
  class Account < ApplicationRecord; end

  def up
    Relay.find_each do |relay|
      relay_account = Account.find_by(inbox_url: relay.inbox_url)

      if relay_account.nil? # This should not happen
        relay.delete
      else
        relay.update(account: relay_account, uri: relay_account.uri)
      end
    end

    # Blocks reads and writes on relays table, but table is small
    safety_assured do
      change_column_null :relays, :account_id, false
      add_index :relays, :uri, unique: true, algorithm: :concurrently
    end
  end

  def down
    safety_assured do
      change_column_null :relays, :account_id, true
      remove_index :relays, :uri, unique: true, algorithm: :concurrently
    end
  end
end
