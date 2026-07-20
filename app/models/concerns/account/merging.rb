# frozen_string_literal: true

# TODO: remove some time after 4.7.0
module Account::Merging
  extend ActiveSupport::Concern

  ACCOUNT_MERGING_CLASSES = {
    account_id: [
      Status, StatusPin, MediaAttachment, Poll, Report, Tombstone, Favourite,
      Follow, FollowRequest, Block, Mute,
      AccountModerationNote, AccountPin, AccountStat, ListAccount,
      PollVote, Mention, AccountDeletionRequest, AccountNote, FollowRecommendationSuppression,
      Appeal, TagFollow, Quote, Collection, CollectionItem
    ],
    from_account_id: [
      Notification, NotificationPermission, NotificationRequest
    ],
    target_account_id: [
      Follow, FollowRequest, Block, Mute, AccountModerationNote, AccountPin, AccountNote
    ],
    reference_account_id: [CanonicalEmailBlock],
    account_warning_id: [Appeal],
    local_account_id: [SeveredRelationship],
    remote_account_id: [SeveredRelationship],
    quoted_account_id: [Quote],
  }.freeze

  def merge_with!(other_account)
    # Since it's the same remote resource, the remote resource likely
    # already believes we are following/blocking, so it's safe to
    # re-attribute the relationships too. However, during the presence
    # of the index bug users could have *also* followed the reference
    # account already, therefore mass update will not work and we need
    # to check for (and skip past) uniqueness errors

    ACCOUNT_MERGING_CLASSES.each do |attribute, classes|
      classes.each do |klass|
        klass.where({ attribute => other_account.id }).reorder(nil).find_each do |record|
          record.update_attribute(attribute, id)
        rescue ActiveRecord::RecordNotUnique
          next
        end
      end
    end

    # Some follow relationships have moved, so the cache is stale
    Rails.cache.delete_matched("followers_hash:#{id}:*")
    Rails.cache.delete_matched("relationships:#{id}:*")
    Rails.cache.delete_matched("relationships:*:#{id}")
  end
end
