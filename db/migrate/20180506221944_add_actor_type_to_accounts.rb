class AddActorTypeToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :actor_type, :string
  end
end
