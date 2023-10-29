# frozen_string_literal: true

class MigrateNotificationsType < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  TYPES_TO_MIGRATE = {
    'Mention' => :mention,
    'Status' => :reblog,
    'Follow' => :follow,
    'FollowRequest' => :follow_request,
    'Favourite' => :favourite,
    'Poll' => :poll,
  }.freeze

  def up
    TYPES_TO_MIGRATE.each_pair do |activity_type, type|
      Notification.where(activity_type: activity_type, type: nil).in_batches.update_all(type: type)
    end
  end

  def down; end
end
