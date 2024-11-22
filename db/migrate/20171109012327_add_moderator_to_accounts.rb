# frozen_string_literal: true

class AddModeratorToAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :users, :moderator, :bool, default: false, null: false }
  end

  def down
    remove_column :users, :moderator
  end
end
