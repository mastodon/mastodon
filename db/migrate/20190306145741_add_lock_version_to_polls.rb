# frozen_string_literal: true

class AddLockVersionToPolls < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :polls,
        :lock_version,
        :integer,
        null: false,
        default: 0
      )
    end
  end

  def down
    remove_column :polls, :lock_version
  end
end
