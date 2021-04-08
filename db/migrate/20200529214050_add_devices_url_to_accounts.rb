class AddDevicesUrlToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :devices_url, :string
  end
end
