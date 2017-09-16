class CreateProfileChange < ActiveRecord::Migration[5.1]
  def change
    create_table :profile_changes do |t|
      t.bigint :account_id, null: false
      t.attachment :avatar
      t.string "display_name", default: "", null: false
    end

    add_foreign_key :profile_changes, :accounts, column: :account_id, on_delete: :cascade
  end
end
