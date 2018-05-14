# frozen_string_literal: true

class RevertIndexChangeOnStatusesForApiV1AccountsAccountIdStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :statuses, [:account_id, :id, :visibility, :updated_at], order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20180106
    end

    remove_index :statuses, column: [:account_id, :id, :visibility], where: 'visibility IN (0, 1, 2)', algorithm: :concurrently
    remove_index :statuses, column: [:account_id, :id], where: 'visibility = 3', algorithm: :concurrently
  end
end
