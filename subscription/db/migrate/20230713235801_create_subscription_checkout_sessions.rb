class CreateSubscriptionCheckoutSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_checkout_sessions do |t|
      t.bigint :user_id
      t.string :session_id

      t.timestamps
    end
  end
end
