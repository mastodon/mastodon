# frozen_string_literal: true

class AddIndexesToReportsForAccounts < ActiveRecord::Migration[5.0]
  def change
    add_index :reports, :account_id
    add_index :reports, :target_account_id
  end
end
