class CreateWebPushSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :web_push_subscriptions do |t|
      t.string :endpoint
      t.string :key_p256dh
      t.string :key_auth
      t.json :data

      t.timestamps
    end
  end
end
