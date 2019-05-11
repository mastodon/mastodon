# frozen_string_literal: true

class RemoveSuspendedSilencedAccountFields < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :accounts, :suspended, :boolean, null: false, default: false
      remove_column :accounts, :silenced, :boolean, null: false, default: false
    end
  end
end
