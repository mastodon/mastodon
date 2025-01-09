# frozen_string_literal: true

class AddFollowRequestIdToListAccounts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { add_reference :list_accounts, :follow_request, foreign_key: { on_delete: :cascade }, index: false }
    add_index :list_accounts, :follow_request_id, algorithm: :concurrently, where: 'follow_request_id IS NOT NULL'
  end
end
