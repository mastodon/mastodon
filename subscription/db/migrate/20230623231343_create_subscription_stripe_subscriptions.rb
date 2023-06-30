class CreateSubscriptionStripeSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_stripe_subscriptions do |t|
      t.bigint :user_id
      t.bigint :invite_id
      t.string :subscription_id
      t.string :customer_id
      t.string :status

      t.timestamps
    end
  end
end
