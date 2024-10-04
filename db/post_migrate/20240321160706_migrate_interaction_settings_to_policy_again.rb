# frozen_string_literal: true

class MigrateInteractionSettingsToPolicyAgain < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class User < ApplicationRecord
    belongs_to :notification_policy, foreign_key: 'account_id', primary_key: 'account_id', optional: true, inverse_of: false
  end

  class NotificationPolicy < ApplicationRecord; end

  def up
    User.includes(:notification_policy).in_batches do |users|
      NotificationPolicy.insert_all(users.filter_map { |user| policy_for_user(user) })
    end
  end

  def down; end

  private

  def policy_for_user(user)
    deserialized_settings = Oj.load(user.attributes_before_type_cast['settings'])
    return if deserialized_settings.nil?
    return if user.notification_policy.present?

    requires_new_policy = false

    policy = {
      account_id: user.account_id,
      filter_not_followers: false,
      filter_not_following: false,
      filter_private_mentions: true,
    }

    if deserialized_settings['interactions.must_be_follower']
      policy[:filter_not_followers] = true
      requires_new_policy = true
    end

    if deserialized_settings['interactions.must_be_following']
      policy[:filter_not_following] = true
      requires_new_policy = true
    end

    unless deserialized_settings['interactions.must_be_following_dm']
      policy[:filter_private_mentions] = false
      requires_new_policy = true
    end

    policy if requires_new_policy
  end
end
