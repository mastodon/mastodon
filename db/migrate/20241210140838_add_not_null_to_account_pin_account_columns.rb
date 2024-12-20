# frozen_string_literal: true

class AddNotNullToAccountPinAccountColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM account_pins
      WHERE account_id IS NULL
      OR target_account_id IS NULL
    SQL

    safety_assured do
      change_column_null :account_pins, :account_id, false
      change_column_null :account_pins, :target_account_id, false
    end
  end

  def down
    safety_assured do
      change_column_null :account_pins, :account_id, true
      change_column_null :account_pins, :target_account_id, true
    end
  end
end
