class CreateWebPushSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :web_push_subscriptions do |t|
      t.integer :account_id
      t.string :endpoint
      t.string :key_p256dh
      t.string :key_auth

      t.timestamps
    end
  end
end
