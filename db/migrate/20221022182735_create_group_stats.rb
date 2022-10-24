class CreateGroupStats < ActiveRecord::Migration[6.1]
  def change
    create_table :group_stats do |t|
      t.belongs_to :group, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.bigint :statuses_count, default: 0, null: false
      t.bigint :members_count, default: 0, null: false
      t.datetime :last_status_at

      t.timestamps
    end
  end
end
