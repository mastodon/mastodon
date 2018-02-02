class AddWebPushSubscriptionToSessionActivations < ActiveRecord::Migration[5.1]
  def change
    add_column :session_activations, :web_push_subscription_id, :integer
  end
end
