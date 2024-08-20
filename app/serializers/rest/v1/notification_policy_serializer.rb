# frozen_string_literal: true

class REST::V1::NotificationPolicySerializer < ActiveModel::Serializer
  attributes :filter_not_following,
             :filter_not_followers,
             :filter_new_accounts,
             :filter_private_mentions,
             :summary

  def summary
    {
      pending_requests_count: object.pending_requests_count.to_i,
      pending_notifications_count: object.pending_notifications_count.to_i,
    }
  end

  def filter_not_following
    !object.accept_not_following?
  end

  def filter_not_followers
    !object.accept_not_followers?
  end

  def filter_new_accounts
    !object.accept_new_accounts?
  end

  def filter_private_mentions
    !object.accept_private_mentions?
  end
end
