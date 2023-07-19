# frozen_string_literal: true

class CreateWebPushSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :web_push_subscriptions do |t|
      t.string :endpoint, null: false
      t.string :key_p256dh, null: false
      t.string :key_auth, null: false
      t.json :data

      t.timestamps
    end
  end
end
