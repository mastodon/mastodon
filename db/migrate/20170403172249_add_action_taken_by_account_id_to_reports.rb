# frozen_string_literal: true

class AddActionTakenByAccountIdToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :action_taken_by_account_id, :integer
  end
end
