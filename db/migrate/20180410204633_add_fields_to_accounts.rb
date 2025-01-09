# frozen_string_literal: true

class AddFieldsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :fields, :jsonb
  end
end
