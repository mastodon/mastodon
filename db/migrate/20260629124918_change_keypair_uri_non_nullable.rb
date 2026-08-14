# frozen_string_literal: true

class ChangeKeypairUriNonNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :keypairs, :uri, true
  end
end
