# frozen_string_literal: true

class AddAlsoKnownAsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :also_known_as, :string, array: true
  end
end
