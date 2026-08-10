# frozen_string_literal: true

class CreateModerationSubscriptionAdvisories < ActiveRecord::Migration[8.1]
  def change
    create_table :moderation_subscription_advisories do |t|
      t.belongs_to :moderation_subscription, null: false, foreign_key: true
      t.integer :action, null: false
      t.integer :target_type, null: false
      t.string :target_key, null: false

      t.timestamps
    end

    add_index :moderation_subscription_advisories, [:target_type, :target_key, :moderation_subscription_id], unique: true
  end
end
