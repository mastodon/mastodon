# frozen_string_literal: true
# == Schema Information
#
# Table name: relays
#
#  id                 :bigint(8)        not null, primary key
#  inbox_url          :string           default(""), not null
#  enabled            :boolean          default(FALSE), not null
#  follow_activity_id :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Relay < ApplicationRecord
  PRESET_RELAY = 'https://relay.joinmastodon.org/inbox'

  validates :inbox_url, presence: true, uniqueness: true, url: true, if: :will_save_change_to_inbox_url?

  scope :enabled, -> { where(enabled: true) }

  before_destroy :ensure_disabled

  def enable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(follow_activity(activity_id))

    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
    update(enabled: true, follow_activity_id: activity_id)
  end

  def disable!
    activity_id = ActivityPub::TagManager.instance.generate_uri_for(nil)
    payload     = Oj.dump(unfollow_activity(activity_id))

    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
    update(enabled: false, follow_activity_id: nil)
  end

  private

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
    @some_local_account ||= Account.local.find_by(suspended: false)
  end

  def ensure_disabled
    return unless enabled?
    disable!
  end
end
