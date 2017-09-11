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

    ActivityPub::RawDistributionWorker.push_bulk(status.reblogs.includes(:account).references(:account).merge(Account.local).pluck(:account_id)) do |account_id|
      [payload, account_id]
    end
  end

  def delete_now!(status)
    RemoveStatusService.new.call(status)
  end

  def payload
    @payload ||= Oj.dump(@json)
  end
end
