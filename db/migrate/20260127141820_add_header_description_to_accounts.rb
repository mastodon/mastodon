# frozen_string_literal: true

class AddHeaderDescriptionToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :header_description, :string, null: false, default: ''
  end
end
