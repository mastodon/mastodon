# frozen_string_literal: true

class AddRuleViolationsToAccountWarningTable < ActiveRecord::Migration[8.1]
  def up
    add_column :account_warnings, :rule_ids, :bigint, array: true
  end

  def down
    remove_column :account_warnings, :rule_ids
  end
end
