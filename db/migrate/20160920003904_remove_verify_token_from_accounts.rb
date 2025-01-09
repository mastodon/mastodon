# frozen_string_literal: true

class RemoveVerifyTokenFromAccounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :accounts, :verify_token, :string, null: false, default: ''
  end
end
