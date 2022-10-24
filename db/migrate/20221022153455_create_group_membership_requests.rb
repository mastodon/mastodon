class CreateGroupMembershipRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :group_membership_requests do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.belongs_to :group, null: false, foreign_key: { on_delete: :cascade }

      t.string :uri

      t.timestamps
    end

    add_index :group_membership_requests, [:account_id, :group_id], unique: true
    add_index :group_membership_requests, :uri, unique: true, opclass: :text_pattern_ops, where: '(uri IS NOT NULL)'
  end
end
