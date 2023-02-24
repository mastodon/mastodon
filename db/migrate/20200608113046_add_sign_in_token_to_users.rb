class AddSignInTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.column :sign_in_token, :string
      t.column :sign_in_token_sent_at, :datetime
    end
  end
end
