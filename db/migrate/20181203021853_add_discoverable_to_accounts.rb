# frozen_string_literal: true

class AddDiscoverableToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :discoverable, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
