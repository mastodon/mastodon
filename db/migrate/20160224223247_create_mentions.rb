class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :account_id
      t.integer :status_id

      t.timestamps null: false
    end

    add_index :mentions, [:account_id, :status_id], unique: true
  end
end
