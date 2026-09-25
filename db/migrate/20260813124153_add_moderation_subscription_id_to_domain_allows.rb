# frozen_string_literal: true

class AddModerationSubscriptionIdToDomainAllows < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :domain_allows, :moderation_subscription, null: true, index: { algorithm: :concurrently }
  end
end
