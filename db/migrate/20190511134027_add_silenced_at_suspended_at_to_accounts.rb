class AddSilencedAtSuspendedAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :silenced_at, :datetime
    add_column :accounts, :suspended_at, :datetime
  end
end
