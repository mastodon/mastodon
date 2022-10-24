class CreateGroupDeletionRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :group_deletion_requests do |t|
      t.references :group, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
