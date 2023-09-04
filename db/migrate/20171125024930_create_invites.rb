class CreateInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :invites do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }
      t.string :code, null: false, default: ''
      t.datetime :expires_at, null: true, default: nil
      t.integer :max_uses, null: true, default: nil
      t.integer :uses, null: false, default: 0

      t.timestamps
    end

    add_index :invites, :code, unique: true
  end
end
