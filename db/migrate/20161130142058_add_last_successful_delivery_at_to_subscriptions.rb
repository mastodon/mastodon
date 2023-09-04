class AddLastSuccessfulDeliveryAtToSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :subscriptions, :last_successful_delivery_at, :datetime, null: true, default: nil
  end
end
