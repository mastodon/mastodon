# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    if @account.uri == object_uri
      delete_person
    else
      delete_note
    end
  end

  private

  def delete_person
    lock_or_return("delete_in_progress:#{@account.id}") do
      SuspendAccountService.new.call(@account, reserve_username: false)
    end
  end

  def delete_note
    return if object_uri.nil?

    unless invalid_origin?(object_uri)
      RedisLock.acquire(lock_options) { |_lock| delete_later!(object_uri) }
      Tombstone.find_or_create_by(uri: object_uri, account: @account)
    end

    @status   = Status.find_by(uri: object_uri, account: @account)
    @status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

    return if @status.nil?

    if @status.distributable?
      forward_for_reply
      forward_for_reblogs
    end

    delete_now!
  end

  def forward_for_reblogs
    return if @json['signature'].blank?

    rebloggers_ids = @status.reblogs.includes(:account).references(:account).merge(Account.local).pluck(:account_id)
    inboxes        = Account.where(id: ::Follow.where(target_account_id: rebloggers_ids).select(:account_id)).inboxes - [@account.preferred_inbox_url]

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, rebloggers_ids.first, inbox_url]
    end
  end

  def replied_to_status
    return @replied_to_status if defined?(@replied_to_status)
    @replied_to_status = @status.thread
  end

  def reply_to_local?
    !replied_to_status.nil? && replied_to_status.account.local?
  end

  def forward_for_reply
    return unless @json['signature'].present? && reply_to_local?

    inboxes = replied_to_status.account.followers.inboxes - [@account.preferred_inbox_url]

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, replied_to_status.account_id, inbox_url]
    end
  end

  def delete_now!
    RemoveStatusService.new.call(@status, redraft: false)
  end

  def payload
    @payload ||= Oj.dump(@json)
  end

  def lock_options
    { redis: Redis.current, key: "create:#{object_uri}" }
  end
end
