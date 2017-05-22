class AddIndexAccountsOnUri < ActiveRecord::Migration[5.0]
  def change
    add_index :accounts, :uri
  end
end
