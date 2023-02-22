# frozen_string_literal: true

class AddURLToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :url, :string, null: true, default: nil
  end
end
