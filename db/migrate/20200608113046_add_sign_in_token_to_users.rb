class AddSignInTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sign_in_token, :string
    add_column :users, :sign_in_token_sent_at, :datetime
  end
end
