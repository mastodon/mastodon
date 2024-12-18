# frozen_string_literal: true

class AddProfileFieldsToAccounts < ActiveRecord::Migration[4.2]
  def change
    change_table :accounts, bulk: true do |t|
      t.column :note, :text, null: false, default: ''
      t.column :display_name, :string, null: false, default: ''
      t.column :uri, :string, null: false, default: ''
    end
  end
end
