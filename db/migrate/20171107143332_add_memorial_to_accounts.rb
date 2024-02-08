# frozen_string_literal: true

class AddMemorialToAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :accounts, :memorial, :bool, default: false, null: false }
  end

  def down
    remove_column :accounts, :memorial
  end
end
