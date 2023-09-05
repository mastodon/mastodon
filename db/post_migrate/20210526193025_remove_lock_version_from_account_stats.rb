# frozen_string_literal: true

class RemoveLockVersionFromAccountStats < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :account_stats, :lock_version, :integer, null: false, default: 0
    end
  end
end
