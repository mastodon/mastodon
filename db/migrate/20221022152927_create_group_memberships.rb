class CreateGroupMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :group_memberships do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.belongs_to :group, null: false, foreign_key: { on_delete: :cascade }, index: false

      t.integer :role, null: false, default: 0

      t.string :uri

      t.timestamps
    end

    add_index :group_memberships, [:account_id, :group_id], unique: true
    add_index :group_memberships, [:group_id, :role]
    add_index :group_memberships, :uri, unique: true, opclass: :text_pattern_ops, where: '(uri IS NOT NULL)'
  end
end
