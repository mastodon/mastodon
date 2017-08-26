# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    status   = Status.find_by(uri: object_uri, account: @account)
    status ||= Status.find_by(uri: @object['_:atomUri'], account: @account) if @object.is_a?(Hash) && @object['_:atomUri'].present?

    if status.nil?
      delete_later!(object_uri)
    else
      RemoveStatusService.new.call(status)
    end
  end
end
