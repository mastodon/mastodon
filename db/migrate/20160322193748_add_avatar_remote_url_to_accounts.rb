class AddAvatarRemoteURLToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :avatar_remote_url, :string, null: true, default: nil
  end
end
