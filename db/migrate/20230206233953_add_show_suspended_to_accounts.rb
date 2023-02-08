class AddShowSuspendedToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :show_suspended, :boolean
  end
end
