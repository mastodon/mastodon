# frozen_string_literal: true

class AddCategoryToReports < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_column :reports, :category, :int, default: 0, null: false
      change_table(:reports, bulk: true) do |t|
        t.column :action_taken_at, :datetime
        t.column :rule_ids, :bigint, array: true
      end
      execute 'UPDATE reports SET action_taken_at = updated_at WHERE action_taken = TRUE'
    end
  end

  def down
    safety_assured do
      execute 'UPDATE reports SET action_taken = TRUE WHERE action_taken_at IS NOT NULL'
      remove_column :reports, :category
      change_table(:reports, bulk: true) do |t|
        t.column :action_taken_at, :datetime
        t.column :rule_ids, :bigint, array: true
      end
    end
  end
end
