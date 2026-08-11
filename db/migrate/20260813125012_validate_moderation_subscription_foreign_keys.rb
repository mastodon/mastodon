# frozen_string_literal: true

class ValidateModerationSubscriptionForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :domain_blocks, :moderation_subscriptions
    validate_foreign_key :domain_allows, :moderation_subscriptions
  end
end
