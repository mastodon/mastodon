class AddAvatarRemoteUrlToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :avatar_remote_url, :string, null: true, default: nil
  end
end
