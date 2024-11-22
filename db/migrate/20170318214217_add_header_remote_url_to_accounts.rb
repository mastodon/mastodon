# frozen_string_literal: true

class AddHeaderRemoteURLToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :header_remote_url, :string, null: false, default: ''
  end
end
