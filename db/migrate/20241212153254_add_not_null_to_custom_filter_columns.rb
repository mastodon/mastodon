# frozen_string_literal: true

class AddNotNullToCustomFilterColumns < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM custom_filters
      WHERE account_id IS NULL
    SQL

    safety_assured { change_column_null :custom_filters, :account_id, false }
  end

  def down
    safety_assured { change_column_null :custom_filters, :account_id, true }
  end
end
