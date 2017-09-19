# frozen_string_literal: true

class ActivityPub::FollowerCollectionSerializer < ActiveModel::Serializer
  attributes :id, :type, :total_items

  has_many :ordered_items

  def id
    account_followers_url object.account
  end

  def type
    'OrderedCollection'
  end

  def total_items
    object.account.followers_count
  end

  def ordered_items
    Follow.where(target_account: object.account)
          .recent
          .merge(object.scope)
          .pluck(:account)
          .each do |account|
      ActivityPub::TagManager.instance.uri_for account
    end
  end
end
