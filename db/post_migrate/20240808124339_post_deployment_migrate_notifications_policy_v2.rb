# frozen_string_literal: true

class PostDeploymentMigrateNotificationsPolicyV2 < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class NotificationPolicy < ApplicationRecord; end

  def up
    NotificationPolicy.in_batches.update_all(<<~SQL.squish)
      for_not_following = CASE filter_not_following WHEN true THEN 1 ELSE 0 END,
      for_not_followers = CASE filter_not_following WHEN true THEN 1 ELSE 0 END,
      for_new_accounts = CASE filter_new_accounts WHEN true THEN 1 ELSE 0 END,
      for_private_mentions = CASE filter_private_mentions WHEN true THEN 1 ELSE 0 END
    SQL
  end

  def down
    NotificationPolicy.in_batches.update_all(<<~SQL.squish)
      filter_not_following = CASE for_not_following WHEN 0 THEN false ELSE true END,
      filter_not_following = CASE for_not_followers WHEN 0 THEN false ELSE true END,
      filter_new_accounts = CASE for_new_accounts WHEN 0 THEN false ELSE true END,
      filter_private_mentions = CASE for_private_mentions WHEN 0 THEN false ELSE true END
    SQL
  end
end
