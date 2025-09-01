# frozen_string_literal: true

class AddDeliveryLastFailedAtToFaspProviders < ActiveRecord::Migration[8.0]
  def change
    add_column :fasp_providers, :delivery_last_failed_at, :datetime
  end
end
