# frozen_string_literal: true

class AddQuoteApprovalPolicyToStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column :statuses, :quote_approval_policy, :integer
  end
end
