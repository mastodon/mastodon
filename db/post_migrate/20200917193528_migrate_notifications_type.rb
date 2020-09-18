# frozen_string_literal: true

class MigrateNotificationsType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  TYPES_TO_MIGRATE = %w(
    Mention
    Status
    Follow
    FollowRequest
    Favourite
    Poll
  ).freeze

  def up
    TYPES_TO_MIGRATE.each do |activity_type|
      Notification.where(activity_type: activity_type, type: nil).in_batches.update_all(type: activity_type.underscore)
    end
  end

  def down; end
end
