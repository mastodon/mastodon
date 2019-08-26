class AddHideFollowersAndFollowingToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :hide_followers, :boolean
    add_column :accounts, :hide_following, :boolean
  end
end
