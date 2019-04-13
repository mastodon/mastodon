class AddDiscoverableToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :discoverable, :boolean
  end
end
