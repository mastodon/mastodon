# frozen_string_literal: true

class AddHasFederatedToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :has_federated, :boolean, null: false, default: true
  end
end
