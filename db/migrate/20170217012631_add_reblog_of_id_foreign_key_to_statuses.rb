class AddReblogOfIdForeignKeyToStatuses < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :statuses, :statuses, column: :reblog_of_id, on_delete: :cascade
  end
end
