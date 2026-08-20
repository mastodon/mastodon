# frozen_string_literal: true

class ChangeAccountUriNullable < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  class Account < ApplicationRecord; end

  def up
    change_column_null :accounts, :uri, true
  end

  def down
    change_column_null :accounts, :uri, false
  rescue ActiveRecord::NotNullViolation
    Account.where(uri: nil).update_all(uri: '')

    retry
  end
end
