class AddActivitystreams2UrlToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :activitystreams2_url, :string, null: false, default: ''
  end
end
