# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    status   = Status.find_by(uri: object_uri, account: @account)
    status ||= Status.find_by(uri: @object['_:atomUri'], account: @account) if @object.is_a?(Hash) && @object['_:atomUri'].present?

    if status.nil?
      delete_later!(object_uri)
    else
      forward_for_reblogs(status)
      delete_now!(status)
    end
  end

  private

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
