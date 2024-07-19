# frozen_string_literal: true

class AddIndexableToAccounts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :accounts, :indexable, :boolean, default: false, null: false }
  end

  def down
    remove_column :accounts, :indexable
  end
end
