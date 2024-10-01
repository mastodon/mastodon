# frozen_string_literal: true

class REST::NotificationPolicySerializer < ActiveModel::Serializer
  # Please update `app/javascript/mastodon/api_types/notification_policies.ts` when making changes to the attributes

  attributes :for_not_following,
             :for_not_followers,
             :for_new_accounts,
             :for_private_mentions,
             :for_limited_accounts,
             :summary

  def summary
    {
      pending_requests_count: object.pending_requests_count.to_i,
      pending_notifications_count: object.pending_notifications_count.to_i,
    }
  end
end
