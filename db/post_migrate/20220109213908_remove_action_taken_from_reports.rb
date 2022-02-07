# frozen_string_literal: true

class RemoveActionTakenFromReports < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { remove_column :reports, :action_taken, :boolean, default: false, null: false }
  end
end
