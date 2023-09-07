# frozen_string_literal: true

class AddIndexReportsOnAssignedAccountId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :reports, [:assigned_account_id], name: :index_reports_on_assigned_account_id, algorithm: :concurrently, where: 'assigned_account_id IS NOT NULL'
  end
end
