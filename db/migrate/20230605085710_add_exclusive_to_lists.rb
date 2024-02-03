# frozen_string_literal: true

class AddExclusiveToLists < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :lists, :exclusive, :boolean, default: false, null: false }
  end

  def down
    remove_column :lists, :exclusive
  end
end
