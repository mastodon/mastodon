# frozen_string_literal: true

class RemovePrivateKeyFromAccounts < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :accounts, :private_key, :text, null: true }
  end
end
