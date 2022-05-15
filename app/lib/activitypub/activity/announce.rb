# frozen_string_literal: true

class ActivityPub::Activity::Announce < ActivityPub::Activity
  def perform
    return reject_payload! if delete_arrived_first?(@json['id']) || !related_to_local_activity?

    with_lock("announce:#{value_or_id(@object)}") do
      original_status = status_from_object

      return reject_payload! if original_status.nil? || !announceable?(original_status)
      return if requested_through_relay?

      @status = Status.find_by(account: @account, reblog: original_status)

      return @status unless @status.nil?

      @status = Status.create!(
        account: @account,
        reblog: original_status,
        uri: @json['id'],
        created_at: @json['published'],
        override_timestamps: @options[:override_timestamps],
        visibility: visibility_from_audience
      )

      Trends.register!(@status)

      distribute
    end

    @status
  end

  private

  def distribute
    # Notify the author of the original status if that status is local
    LocalNotificationWorker.perform_async(@status.reblog.account_id, @status.id, 'Status', 'reblog') if reblog_of_local_account?(@status) && !reblog_by_following_group_account?(@status)

    # Distribute into home and list feeds
    ::DistributionWorker.perform_async(@status.id) if @options[:override_timestamps] || @status.within_realtime_window?
  end

  def reblog_of_local_account?(status)
    status.reblog? && status.reblog.account.local?
  end

  def reblog_by_following_group_account?(status)
    status.reblog? && status.account.group? && status.reblog.account.following?(status.account)
  end

  def audience_to
    as_array(@json['to']).map { |x| value_or_id(x) }
  end

  def audience_cc
    as_array(@json['cc']).map { |x| value_or_id(x) }
  end

  def visibility_from_audience
    if audience_to.any? { |to| ActivityPub::TagManager.instance.public_collection?(to) }
      :public
    elsif audience_cc.any? { |cc| ActivityPub::TagManager.instance.public_collection?(cc) }
      :unlisted
    elsif audience_to.include?(@account.followers_url)
      :private
    else
      :direct
    end
  end

  def announceable?(status)
    status.account_id == @account.id || status.distributable?
  end

  def related_to_local_activity?
    followed_by_local_accounts? || requested_through_relay? || reblog_of_local_status?
  end

  def requested_through_relay?
    super || Relay.find_by(inbox_url: @account.inbox_url)&.enabled?
  end

  def reblog_of_local_status?
    status_from_uri(object_uri)&.account&.local?
  end
end
