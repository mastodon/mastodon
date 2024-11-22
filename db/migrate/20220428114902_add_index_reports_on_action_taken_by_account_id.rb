# frozen_string_literal: true

class AddIndexReportsOnActionTakenByAccountId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :reports, [:action_taken_by_account_id], name: :index_reports_on_action_taken_by_account_id, algorithm: :concurrently, where: 'action_taken_by_account_id IS NOT NULL'
  end
end
