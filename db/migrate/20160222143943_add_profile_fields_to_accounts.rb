# frozen_string_literal: true

class AddProfileFieldsToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :note, :text, null: false, default: ''
    add_column :accounts, :display_name, :string, null: false, default: ''
    add_column :accounts, :uri, :string, null: false, default: ''
  end
end
