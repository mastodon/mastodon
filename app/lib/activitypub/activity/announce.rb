# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  def perform
    original_status   = status_from_uri(object_uri)
    original_status ||= fetch_remote_original_status

    return if original_status.nil? || delete_arrived_first?(@json['id']) || !announceable?(original_status)

    status = Status.find_by(account: @account, reblog: original_status)

    return status unless status.nil?

    status = Status.create!(
      account: @account,
      reblog: original_status,
      uri: @json['id'],
      created_at: @json['published'],
      override_timestamps: @options[:override_timestamps],
      visibility: visibility_from_audience
    )

    distribute(status)
    status
  end

  private

  def visibility_from_audience
    if equals_or_includes?(@json['to'], ActivityPub::TagManager::COLLECTIONS[:public])
      :public
    elsif equals_or_includes?(@json['cc'], ActivityPub::TagManager::COLLECTIONS[:public])
      :unlisted
    elsif equals_or_includes?(@json['to'], @account.followers_url)
      :private
    else
      :direct
    end
  end

  def announceable?(status)
    status.account_id == @account.id || status.public_visibility? || status.unlisted_visibility?
  end
end
