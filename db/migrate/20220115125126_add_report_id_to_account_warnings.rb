# frozen_string_literal: true

class AddReportIdToAccountWarnings < ActiveRecord::Migration[6.1]
  def change
    safety_assured { add_reference :account_warnings, :report, foreign_key: { on_delete: :cascade }, index: false }
    add_column :account_warnings, :status_ids, :string, array: true
  end
end
