# frozen_string_literal: true

class AddIndexOnStatusesForApiV1AccountsAccountIdStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :statuses, [:account_id, :id, :visibility, :updated_at], order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20180106 # rubocop:disable Naming/VariableNumber
    end
    remove_index :statuses, [:account_id, :id], name: :index_statuses_on_account_id_id
  end
end
