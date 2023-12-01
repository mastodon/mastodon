# frozen_string_literal: true

class MigrateWebPushSubscriptions2 < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Web::PushSubscription.where(user_id: nil).select(:id).includes(:session_activation).find_each do |subscription|
      if subscription.session_activation.nil?
        subscription.delete
      else
        subscription.update_attribute(:user_id, subscription.session_activation.user_id)
      end
    end
  end

  def down
    # Nothing to do
  end
end
