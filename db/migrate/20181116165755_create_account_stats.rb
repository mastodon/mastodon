class CreateAccountStats < ActiveRecord::Migration[5.2]
  def change
    create_table :account_stats do |t|
      t.belongs_to :account, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.bigint :statuses_count, null: false, default: 0
      t.bigint :following_count, null: false, default: 0
      t.bigint :followers_count, null: false, default: 0

      t.timestamps
    end
  end
end
