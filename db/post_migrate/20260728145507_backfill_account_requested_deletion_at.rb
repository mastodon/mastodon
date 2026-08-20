# frozen_string_literal: true

class BackfillAccountRequestedDeletionAt < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<~SQL
        UPDATE
          accounts
        SET
          requested_deletion_at = suspended_at, suspended_at = NULL, suspension_origin = NULL
        WHERE
          -- rule out remote accounts, as deleted remote accounts are deleted locally
          domain IS NULL
          -- only care about accounts marked as suspended (which prior to this migration applies to both suspended and self-deleted accounts)
          AND suspended_at IS NOT NULL
          -- rule accounts that were not self-deleted (might still include suspended but self-deleted accounts)
          AND NOT EXISTS (SELECT 1 FROM users WHERE account_id = accounts.id) AND NOT EXISTS (SELECT 1 FROM canonical_email_blocks WHERE reference_account_id = accounts.id)
          -- rule out accounts that have a canonical email block: sign they were suspended and not unsuspended
          AND NOT EXISTS (SELECT 1 FROM canonical_email_blocks WHERE reference_account_id = accounts.id)
      SQL
    end
  end

  def down
    safety_assured do
      execute 'UPDATE accounts SET suspended_at = requested_deletion_at WHERE domain is NULL AND suspended_at IS NULL AND requested_deletion_at IS NOT NULL'
    end
  end
end
