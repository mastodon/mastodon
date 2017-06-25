class AddWebDomainToAccounts < ActiveRecord::Migration[5.0]
  def up
    add_column :accounts, :web_domain, :string, null: true, default: nil
  end

  def down
    remove_column :accounts, :web_domain
  end
end
