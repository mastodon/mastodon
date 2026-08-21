# frozen_string_literal: true

class CreateModerationSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :moderation_subscriptions do |t|
      t.string :name
      t.integer :type, null: false
      t.string :url, null: false
      t.integer :list_action
      t.integer :priority
      t.boolean :apply_automatically, null: false, default: false
      t.boolean :retract_automatically, null: false, default: true
      t.boolean :preserve_relationships, null: false, default: true
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
