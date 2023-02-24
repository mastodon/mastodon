class AddConfirmableToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users, bulk: true do |t|
      t.column :confirmation_token, :string
      t.column :confirmed_at, :datetime
      t.column :confirmation_sent_at, :datetime
      t.column :unconfirmed_email, :string
      t.index :confirmation_token, unique: true
    end
  end
end
