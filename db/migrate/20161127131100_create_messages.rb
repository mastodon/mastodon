class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :account_id, null: false
      t.integer :private_recipient_id, null: false
      t.text :text, null: false, default: ''

      t.timestamps null: false
    end
  end
end
