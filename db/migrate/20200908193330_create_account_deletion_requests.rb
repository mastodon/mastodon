class CreateAccountDeletionRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :account_deletion_requests do |t|
      t.references :account, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
