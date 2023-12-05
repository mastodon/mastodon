# frozen_string_literal: true

class AddSilencedToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :silenced, :boolean, null: false, default: false
  end
end
