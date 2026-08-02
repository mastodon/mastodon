# frozen_string_literal: true

class RemoveEmailSubscriptionsDuplicateIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :email_subscriptions, :account_id
  end
end
