# frozen_string_literal: true

class CreateEmergencySettingOverrideActions < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_setting_override_actions do |t|
      t.belongs_to :emergency_rule, foreign_key: { on_delete: :cascade }, null: false

      t.string :setting, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
