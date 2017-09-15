# frozen_string_literal: true

class ActivityPub::FollowingCollectionSerializer < ActiveModel::Serializer
  attributes :id, :type, :total_items

  has_many :ordered_items

  def id
    account_following_index_url object.id
  end

  def type
    'OrderedCollection'
  end

  def total_items
    object.account.following_count
  end

  def ordered_items
    Follow.where(account: object.account)
          .recent
          .merge(object.scope)
          .pluck(:target_account)
          .each do |account|
      ActivityPub::TagManager.instance.uri_for account
    end
  end
end
