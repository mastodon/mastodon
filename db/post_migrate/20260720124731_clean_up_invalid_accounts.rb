# frozen_string_literal: true

class CleanUpInvalidAccounts < ActiveRecord::Migration[8.1]
  # Dummy classes to make migration possible across version changes
  class Account < ApplicationRecord; end

  def up
    # A very old bug could cause incompletely-processed remote accounts to be added
    # to the database; those would not have a URI, which could be an issue in the
    # future. Delete them.
    Account.where.not(domain: nil).where(uri: nil).in_batches.delete_all
  end

  def down; end
end
