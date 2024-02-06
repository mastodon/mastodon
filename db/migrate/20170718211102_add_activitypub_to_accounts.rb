# frozen_string_literal: true

class AddActivityPubToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :inbox_url, :string, null: false, default: ''
    add_column :accounts, :outbox_url, :string, null: false, default: ''
    add_column :accounts, :shared_inbox_url, :string, null: false, default: ''
    add_column :accounts, :followers_url, :string, null: false, default: ''
    add_column :accounts, :protocol, :integer, null: false, default: 0
  end
end
