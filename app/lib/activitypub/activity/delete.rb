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
      DeleteAccountService.new.call(@account, reserve_username: false, skip_activitypub: true)
    end
  end

  def delete_note
    return if object_uri.nil?

    lock_or_return("delete_status_in_progress:#{object_uri}", 5.minutes.seconds) do
      unless invalid_origin?(object_uri)
        # This lock ensures a concurrent `ActivityPub::Activity::Create` either
        # does not create a status at all, or has finished saving it to the
        # database before we try to load it.
        # Without the lock, `delete_later!` could be called after `delete_arrived_first?`
        # and `Status.find` before `Status.create!`
        lock_or_fail("create:#{object_uri}") { delete_later!(object_uri) }

        Tombstone.find_or_create_by(uri: object_uri, account: @account)
      end

      @status   = Status.find_by(uri: object_uri, account: @account)
      @status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

      return if @status.nil?

      forward! if @json['signature'].present? && @status.distributable?
      delete_now!
    end
  end

  def rebloggers_ids
    return @rebloggers_ids if defined?(@rebloggers_ids)
    @rebloggers_ids = @status.reblogs.includes(:account).references(:account).merge(Account.local).pluck(:account_id)
  end

  def inboxes_for_reblogs
    Account.where(id: ::Follow.where(target_account_id: rebloggers_ids).select(:account_id)).inboxes
  end

  def replied_to_status
    return @replied_to_status if defined?(@replied_to_status)
    @replied_to_status = @status.thread
  end

  def reply_to_local?
    !replied_to_status.nil? && replied_to_status.account.local?
  end

  def inboxes_for_reply
    replied_to_status.account.followers.inboxes
  end

  def forward!
    inboxes = inboxes_for_reblogs
    inboxes += inboxes_for_reply if reply_to_local?
    inboxes -= [@account.preferred_inbox_url]

    sender_id = reply_to_local? ? replied_to_status.account_id : rebloggers_ids.first

    ActivityPub::LowPriorityDeliveryWorker.push_bulk(inboxes.uniq) do |inbox_url|
      [payload, sender_id, inbox_url]
    end
  end

  def delete_now!
    RemoveStatusService.new.call(@status)
  end

  def payload
    @payload ||= Oj.dump(@json)
  end
end
