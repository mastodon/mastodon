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
    SuspendAccountService.new.call(@account)
    @account.destroy!
  end

  def delete_note
    status   = Status.find_by(uri: object_uri, account: @account)
    status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

    delete_later!(object_uri)

    return if status.nil?

    forward_for_reblogs(status)
    delete_now!(status)
  end

  def forward_for_reblogs(status)
    return if @json['signature'].blank?

    rebloggers_ids = status.reblogs.includes(:account).references(:account).merge(Account.local).pluck(:account_id)
    inboxes        = Account.where(id: ::Follow.where(target_account_id: rebloggers_ids).select(:account_id)).inboxes - [@account.preferred_inbox_url]

    ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
      [payload, rebloggers_ids.first, inbox_url]
    end
  end

  def delete_now!(status)
    RemoveStatusService.new.call(status)
  end

  def payload
    @payload ||= Oj.dump(@json)
  end
end
