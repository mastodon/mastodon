# frozen_string_literal: true

class AddActivityPubToAccounts < ActiveRecord::Migration[5.1]
  def change
    change_table(:accounts, bulk: true) do |t|
      t.column :inbox_url, :string, null: false, default: ''
      t.column :outbox_url, :string, null: false, default: ''
      t.column :shared_inbox_url, :string, null: false, default: ''
      t.column :followers_url, :string, null: false, default: ''
      t.column :protocol, :integer, null: false, default: 0
    end
  end
end
