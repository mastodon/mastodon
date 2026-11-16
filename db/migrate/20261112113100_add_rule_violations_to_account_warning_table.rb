# frozen_string_literal: true

class AddRuleViolationsToAccountWarningTable < ActiveRecord::Migration[8.1]
  def up
    add_column :account_warnings, :include_rule_violations, :boolean, null: false, default: false
  end

  def down
    remove_column :account_warnings, :include_rule_violations
  end
end
