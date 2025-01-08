# frozen_string_literal: true

class AddSilencedAtSuspendedAtToAccounts < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  class DomainBlock < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    enum :severity, [:silence, :suspend, :noop]

    has_many :accounts, foreign_key: :domain, primary_key: :domain
  end

  def up
    safety_assured do
      change_table(:accounts, bulk: true) do |t|
        t.column :silenced_at, :datetime
        t.column :suspended_at, :datetime
      end
    end

    # Record suspend date of blocks and silences for users whose limitations match
    # a domain block
    DomainBlock.where(severity: [:silence, :suspend]).find_each do |block|
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

    change_table(:accounts, bulk: true) do |t|
      t.column :silenced_at, :datetime
      t.column :suspended_at, :datetime
    end
  end
end
