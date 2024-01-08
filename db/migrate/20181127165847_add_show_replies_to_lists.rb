# frozen_string_literal: true

class AddShowRepliesToLists < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :lists,
        :replies_policy,
        :integer,
        null: false,
        default: 0
      )
    end
  end

  def down
    remove_column :lists, :replies_policy
  end
end
