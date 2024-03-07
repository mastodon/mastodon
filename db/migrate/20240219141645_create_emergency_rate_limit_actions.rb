# frozen_string_literal: true

class CreateEmergencyRateLimitActions < ActiveRecord::Migration[6.1]
  def change
    create_table :emergency_rate_limit_actions do |t|
      t.belongs_to :emergency_rule, foreign_key: { on_delete: :cascade }, null: false

      t.boolean :new_users_only, null: false, default: false

      t.timestamps
    end
  end
end
