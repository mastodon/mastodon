# frozen_string_literal: true

class BackfillAccountDeletedAt < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute 'UPDATE accounts SET deleted_at = suspended_at, suspended_at = NULL WHERE domain IS NULL AND suspended_at IS NOT NULL AND NOT EXISTS (SELECT 1 FROM users WHERE account_id = accounts.id)'
    end
  end

  def down
    safety_assured do
      'UPDATE accounts SET suspended_at = deleted_at WHERE domain is NULL AND suspended_at IS NULL AND deleted_at IS NOT NULL'
    end
  end
end
