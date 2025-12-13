# frozen_string_literal: true

class AddPublicIndexToStatuses < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :statuses, [:id, :account_id], name: :index_statuses_public_20200119, algorithm: :concurrently, order: { id: :desc }, where: 'deleted_at IS NULL AND visibility = 0 AND reblog_of_id IS NULL AND ((NOT reply) OR (in_reply_to_account_id = account_id))' # rubocop:disable Naming/VariableNumber
  end

  def down
    remove_index :statuses, name: :index_statuses_public_20200119 # rubocop:disable Naming/VariableNumber
  end
end
