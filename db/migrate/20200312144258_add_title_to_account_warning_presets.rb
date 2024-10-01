# frozen_string_literal: true

class AddTitleToAccountWarningPresets < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured { add_column :account_warning_presets, :title, :string, default: '', null: false }
  end

  def down
    remove_column :account_warning_presets, :title
  end
end
