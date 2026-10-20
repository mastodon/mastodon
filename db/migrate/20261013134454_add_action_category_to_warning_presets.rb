# frozen_string_literal: true

class AddActionCategoryToWarningPresets < ActiveRecord::Migration[8.1]
  def up
    add_column :account_warning_presets, :action_category, :string, default: 'all_actions', null: false

    safety_assured do
      execute(<<~SQL.squish)
        UPDATE account_warning_presets SET action_category = 'all_actions'
        WHERE action_category IS NULL
      SQL
    end
  end

  def down
    remove_column :account_warning_presets, :action_category
  end
end
