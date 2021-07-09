class AddExpoToWebPushSubscriptions < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      change_table(:web_push_subscriptions) do |t|
        t.column :expo, :string
        t.change :key_p256dh, :string, null: true
        t.change :key_auth, :string, null: true
      end
    end
  end
  def down
    safety_assured do
      change_table(:web_push_subscriptions) do |t|
        t.remove :expo
        t.change :key_p256dh, :string, null: false
        t.change :key_auth, :string, null: false
      end
    end
  end
end
