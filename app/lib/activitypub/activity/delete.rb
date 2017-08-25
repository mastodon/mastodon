# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    status = Status.find_by(uri: object_uri, account: @account)

    if status.nil?
      delete_later!(object_uri)
    else
      RemoveStatusService.new.call(status)
    end
  end
end
