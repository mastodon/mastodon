# frozen_string_literal: true

class AddModerationSubscriptionForeignKeys < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :domain_blocks, :moderation_subscriptions, on_delete: :nullify, validate: false
    add_foreign_key :domain_allows, :moderation_subscriptions, on_delete: :nullify, validate: false
  end
end
