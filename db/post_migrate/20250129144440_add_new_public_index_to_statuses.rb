# frozen_string_literal: true

class AddNewPublicIndexToStatuses < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :statuses, [:id, :language, :account_id], name: :index_statuses_public_20250129, algorithm: :concurrently, order: { id: :desc }, where: 'deleted_at IS NULL AND visibility = 0 AND reblog_of_id IS NULL AND ((NOT reply) OR (in_reply_to_account_id = account_id))' # rubocop:disable Naming/VariableNumber
  end
end
