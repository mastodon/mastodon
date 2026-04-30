# frozen_string_literal: true

module Account::Muting
  extend ActiveSupport::Concern

  included do
    # Mute relationships
    with_options class_name: 'Mute', dependent: :destroy do
      has_many :mute_relationships, foreign_key: :account_id, inverse_of: :account
      has_many :muted_by_relationships, foreign_key: :target_account_id, inverse_of: :target_account
    end
    has_many :muting, -> { order(mutes: { id: :desc }) }, through: :mute_relationships, source: :target_account
    has_many :muted_by, -> { order(mutes: { id: :desc }) }, through: :muted_by_relationships, source: :account
  end

  def mute!(target_account, notifications: nil, duration: 0)
    notifications = true if notifications.nil?
    mute_relationships
      .create_with(hide_notifications: notifications)
      .find_or_initialize_by(target_account:).tap do |mute|
        mute.expires_in = duration.zero? ? nil : duration
        mute.save!

        # Optionally save when we are updating existing and values differ
        mute.update!(hide_notifications: notifications) if mute.hide_notifications? != notifications
      end
  end

  def unmute!(target_account)
    mute_relationships
      .find_by(target_account:)
      &.destroy
  end

  def muting?(target_account)
    other_id = target_account.is_a?(Account) ? target_account.id : target_account

    preloaded_relation(:muting, other_id) do
      mute_relationships.exists?(target_account:)
    end
  end
end
