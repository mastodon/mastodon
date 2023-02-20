class AddSilencedAtSuspendedAtToAccounts < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  class DomainBlock < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    enum severity: %i(silence suspend noop)

    has_many :accounts, foreign_key: :domain, primary_key: :domain
  end

  def up
    add_column :accounts, :silenced_at, :datetime
    add_column :accounts, :suspended_at, :datetime

    # Record suspend date of blocks and silences for users whose limitations match
    # a domain block
    DomainBlock.where(severity: %i(silence suspend)).find_each do |block|
      scope = block.accounts
      if block.suspend?
        block.accounts.where(suspended: true).in_batches.update_all(suspended_at: block.created_at)
      else
        block.accounts.where(silenced: true).in_batches.update_all(silenced_at: block.created_at)
      end
    end

    # Set dates for accounts which have limitations not related to a domain block
    Account.where(suspended: true, suspended_at: nil).in_batches.update_all(suspended_at: Time.now.utc)
    Account.where(silenced: true, silenced_at: nil).in_batches.update_all(silenced_at: Time.now.utc)
  end

  def down
    # Block or silence accounts that have a date set
    Account.where(suspended: false).where.not(suspended_at: nil).in_batches.update_all(suspended: true)
    Account.where(silenced: false).where.not(silenced_at: nil).in_batches.update_all(silenced: true)

    remove_column :accounts, :silenced_at
    remove_column :accounts, :suspended_at
  end
end
