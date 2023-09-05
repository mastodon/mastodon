# frozen_string_literal: true

class RemoveTrustLevelFromAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { remove_column :accounts, :trust_level, :integer }
  end
end
