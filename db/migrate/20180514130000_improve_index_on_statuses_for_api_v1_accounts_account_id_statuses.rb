# frozen_string_literal: true

class ImproveIndexOnStatusesForApiV1AccountsAccountIdStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    #  These changes were reverted by migration 20180514140000.
    #  add_index :statuses, [:account_id, :id, :visibility], where: 'visibility IN (0, 1, 2)', algorithm: :concurrently
    #  add_index :statuses, [:account_id, :id], where: 'visibility = 3', algorithm: :concurrently
    #  remove_index :statuses, column: [:account_id, :id, :visibility, :updated_at], order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20180106
  end
end
