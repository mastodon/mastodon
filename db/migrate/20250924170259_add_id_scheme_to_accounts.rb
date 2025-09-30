# frozen_string_literal: true

class AddIdSchemeToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :id_scheme, :integer, default: 0
  end
end
