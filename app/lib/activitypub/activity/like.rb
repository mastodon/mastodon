# frozen_string_literal: true

class ActivityPub::Activity::Like < ActivityPub::Activity
  def perform
    original_status = status_from_uri(object_uri)

    return if original_status.nil? || !original_status.account.local? || delete_arrived_first?(@json['id']) || @account.favourited?(original_status)

    favourite = original_status.favourites.create!(account: @account)
    NotifyService.new.call(original_status.account, favourite)
  end
end
