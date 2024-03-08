# frozen_string_literal: true

class MigrateInteractionSettingsToPolicy < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class Account < ApplicationRecord
    has_one :user, inverse_of: :account
    has_one :notification_policy, inverse_of: :account
  end

  class User < ApplicationRecord
    belongs_to :account
  end

  class NotificationPolicy < ApplicationRecord
    belongs_to :account
  end

  def up
    User.includes(account: :notification_policy).find_each do |user|
      deserialized_settings = Oj.load(user.attributes_before_type_cast['settings'])

      next if deserialized_settings.nil?

      policy = user.account.notification_policy || user.account.build_notification_policy
      requires_new_policy = false

      if deserialized_settings['interactions.must_be_follower']
        policy.filter_not_followers = true
        requires_new_policy = true
      end

      if deserialized_settings['interactions.must_be_following']
        policy.filter_not_following = true
        requires_new_policy = true
      end

      if deserialized_settings['interactions.must_be_following_dm']
        policy.filter_private_mentions = true
        requires_new_policy = true
      end

      policy.save if requires_new_policy && policy.changed?
    end
  end

  def down; end
end
