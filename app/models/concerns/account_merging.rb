# frozen_string_literal: true

module AccountMerging
  extend ActiveSupport::Concern

  def merge_with!(other_account)
    # Since it's the same remote resource, the remote resource likely
    # already believes we are following/blocking, so it's safe to
    # re-attribute the relationships too. However, during the presence
    # of the index bug users could have *also* followed the reference
    # account already, therefore mass update will not work and we need
    # to check for (and skip past) uniqueness errors

    owned_classes = [
      Status, StatusPin, MediaAttachment, Poll, Report, Tombstone, Favourite,
      Follow, FollowRequest, Block, Mute,
      AccountModerationNote, AccountPin, AccountStat, ListAccount,
      PollVote, Mention, AccountDeletionRequest, AccountNote, FollowRecommendationSuppression,
      Appeal
    ]

    owned_classes.each do |klass|
      klass.where(account_id: other_account.id).reorder(nil).find_each do |record|
        record.update_attribute(:account_id, id)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end

    target_classes = [
      Follow, FollowRequest, Block, Mute, AccountModerationNote, AccountPin,
      AccountNote
    ]

    target_classes.each do |klass|
      klass.where(target_account_id: other_account.id).reorder(nil).find_each do |record|
        record.update_attribute(:target_account_id, id)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end

    CanonicalEmailBlock.where(reference_account_id: other_account.id).find_each do |record|
      record.update_attribute(:reference_account_id, id)
    end

    Appeal.where(account_warning_id: other_account.id).find_each do |record|
      record.update_attribute(:account_warning_id, id)
    end

    # Some follow relationships have moved, so the cache is stale
    Rails.cache.delete_matched("followers_hash:#{id}:*")
    Rails.cache.delete_matched("relationships:#{id}:*")
    Rails.cache.delete_matched("relationships:*:#{id}")
  end
end
