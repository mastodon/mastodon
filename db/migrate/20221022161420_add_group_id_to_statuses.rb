class AddGroupIdToStatuses < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # TODO: nullify or delete?
    safety_assured { add_reference :statuses, :group, null: true, default: nil, foreign_key: { on_delete: :cascade }, index: false }
    add_index :statuses, :group_id, algorithm: :concurrently, where: 'group_id IS NOT NULL'
  end
end
