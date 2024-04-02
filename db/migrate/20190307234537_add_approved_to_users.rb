# frozen_string_literal: true

class AddApprovedToUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column(
        :users,
        :approved,
        :bool,
        null: false,
        default: true
      )
    end
  end

  def down
    remove_column :users, :approved
  end
end
