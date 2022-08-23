class CreateGroupAccountBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :group_account_blocks do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.belongs_to :group, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :group_account_blocks, [:account_id, :group_id], unique: true
  end
end
