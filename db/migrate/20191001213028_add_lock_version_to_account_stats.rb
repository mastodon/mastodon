# frozen_string_literal: true

class AddLockVersionToAccountStats < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :account_stats, :lock_version, :integer, null: false, default: 0 }
  end

  def down
    remove_column :account_stats, :lock_version
  end
end
