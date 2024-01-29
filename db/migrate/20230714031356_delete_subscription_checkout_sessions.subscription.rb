# This migration comes from subscription (originally 20230714031107)
class DeleteSubscriptionCheckoutSessions < ActiveRecord::Migration[6.1]
  def change
    drop_table :subscription_checkout_sessions
  end
end
