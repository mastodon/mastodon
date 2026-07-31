# frozen_string_literal: true

class AddRequestedDeletionAtToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :requested_deletion_at, :datetime
  end
end
