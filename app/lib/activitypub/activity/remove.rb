# frozen_string_literal: true

class ActivityPub::Activity::Remove < ActivityPub::Activity
  def perform
    return unless @json['target'].present? && value_or_id(@json['target']) == @account.featured_collection_url

    status = status_from_uri(object_uri)

    return unless status.account_id == @account.id

    pin = StatusPin.find_by(account: @account, status: status)
    pin&.destroy!
  end
end
