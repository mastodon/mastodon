# frozen_string_literal: true

class AddActionCategoryToWarningPresets < ActiveRecord::Migration[8.1]
  def change
    add_column :account_warning_presets, :action_category, :string
  end
end
