# frozen_string_literal: true

class ChangeDefaultsForAccountIdScheme < ActiveRecord::Migration[8.0]
  def change
    change_column_default :accounts, :id_scheme, from: 0, to: 1
  end
end
