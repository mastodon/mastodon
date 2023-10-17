# frozen_string_literal: true

class RemoveSuspendedSilencedAccountFields < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  class DomainBlock < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    enum severity: [:silence, :suspend, :noop]

    has_many :accounts, foreign_key: :domain, primary_key: :domain
  end

  disable_ddl_transaction!

  def up
    # Record suspend date of blocks and silences for users whose limitations match
    # a domain block
    DomainBlock.where(severity: [:silence, :suspend]).find_each do |block|
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

    safety_assured do
      remove_column :accounts, :suspended, :boolean, null: false, default: false
      remove_column :accounts, :silenced, :boolean, null: false, default: false
    end
    Account.reset_column_information
  end

  def down
    safety_assured do
      add_column :accounts, :suspended, :boolean, null: false, default: false
      add_column :accounts, :silenced, :boolean, null: false, default: false
    end
  end
end
