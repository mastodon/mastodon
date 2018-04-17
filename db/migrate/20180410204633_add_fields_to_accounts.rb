class AddFieldsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :fields, :jsonb
  end
end
