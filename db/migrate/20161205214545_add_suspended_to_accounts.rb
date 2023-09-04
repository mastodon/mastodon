class AddSuspendedToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :suspended, :boolean, null: false, default: false
  end
end
