# frozen_string_literal: true

class ClearOrphanedAccountNotes < ActiveRecord::Migration[5.2]
  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  class AccountNote < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account
    belongs_to :target_account, class_name: 'Account'
  end

  def up
    AccountNote.where('NOT EXISTS (SELECT * FROM users u WHERE u.account_id = account_notes.account_id)').in_batches.delete_all
  end

  def down
    # nothing to do
  end
end
