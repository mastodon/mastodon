class CreateReblogsMutes < ActiveRecord::Migration[5.0]
  def change
    create_table :reblogs_mutes do |t|
      t.integer :account_id, null: false
      t.integer :target_account_id, null: false
    end

    add_index :reblogs_mutes, [:account_id, :target_account_id], unique: true
  end
end
