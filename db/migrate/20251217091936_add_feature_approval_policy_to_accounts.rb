# frozen_string_literal: true

class AddFeatureApprovalPolicyToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :feature_approval_policy, :integer, null: false, default: 0
  end
end
