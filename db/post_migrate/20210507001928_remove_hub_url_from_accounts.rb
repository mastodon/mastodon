# frozen_string_literal: true

class RemoveHubURLFromAccounts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :accounts, :secret, :string, null: false, default: ''
      remove_column :accounts, :remote_url, :string, null: false, default: ''
      remove_column :accounts, :salmon_url, :string, null: false, default: ''
      remove_column :accounts, :hub_url, :string, null: false, default: ''
    end
  end
end
