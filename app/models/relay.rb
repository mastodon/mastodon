# frozen_string_literal: true

# == Schema Information
#
# Table name: relays
#
#  id                 :bigint(8)        not null, primary key
#  inbox_url          :string           default(""), not null
#  follow_activity_id :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  state              :integer          default("idle"), not null
#

class Relay < ApplicationRecord
  validates :inbox_url, presence: true, uniqueness: true, url: true # rubocop:disable Rails/UniqueValidationWithoutIndex

  enum :state, { idle: 0, pending: 1, accepted: 2, rejected: 3 }

  scope :enabled, -> { accepted }

  normalizes :inbox_url, with: ->(inbox_url) { inbox_url.strip }

  before_destroy :ensure_disabled

  alias enabled? accepted?

  def to_log_human_identifier
    inbox_url
  end

  def enable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(follow_activity(activity_id))

    update!(state: :pending, follow_activity_id: activity_id)
    reset_delivery_tracker
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  def disable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(unfollow_activity(activity_id))

    update!(state: :idle, follow_activity_id: nil)
    reset_delivery_tracker
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  private

  def reset_delivery_tracker
    DeliveryFailureTracker.reset!(inbox_url)
  end

  def follow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Follow',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: ActivityPub::TagManager::COLLECTIONS[:public],
    }
  end

  def unfollow_activity(activity_id)
    {
      '@context': ActivityPub::TagManager::CONTEXT,
      id: activity_id,
      type: 'Undo',
      actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
      object: {
        id: follow_activity_id,
        type: 'Follow',
        actor: ActivityPub::TagManager.instance.uri_for(some_local_account),
        object: ActivityPub::TagManager::COLLECTIONS[:public],
      },
    }
  end

  def some_local_account
    @some_local_account ||= Account.representative
  end

  def ensure_disabled
    disable! if enabled?
  end
end
