# frozen_string_literal: true

class RemoveOldPublicIndexToStatuses < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_index :statuses, [:id, :account_id], name: :index_statuses_public_20200119, algorithm: :concurrently, order: { id: :desc }, where: 'deleted_at IS NULL AND visibility = 0 AND reblog_of_id IS NULL AND ((NOT reply) OR (in_reply_to_account_id = account_id))' # rubocop:disable Naming/VariableNumber
  end
end
