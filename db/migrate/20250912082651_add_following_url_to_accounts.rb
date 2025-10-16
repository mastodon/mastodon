# frozen_string_literal: true

class AddFollowingURLToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :following_url, :string, default: '', null: false
  end
end
