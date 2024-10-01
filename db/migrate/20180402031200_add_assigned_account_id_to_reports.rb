# frozen_string_literal: true

class AddAssignedAccountIdToReports < ActiveRecord::Migration[5.2]
  def change
    safety_assured { add_reference :reports, :assigned_account, null: true, default: nil, foreign_key: { on_delete: :nullify, to_table: :accounts }, index: false }
  end
end
