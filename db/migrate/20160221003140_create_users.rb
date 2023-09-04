class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ''
      t.integer :account_id, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
