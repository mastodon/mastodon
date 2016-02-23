class AddUrlToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :url, :string, null: true, default: nil
  end
end
