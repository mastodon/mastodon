# frozen_string_literal: true

class REST::NotificationPolicySerializer < ActiveModel::Serializer
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
end
