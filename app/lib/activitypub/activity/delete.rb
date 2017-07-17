# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    status = Status.find_by(uri: object_uri, account: @account)

    if status.nil?
      redis.setex("delete_upon_arrival:#{@account.id}:#{object_uri}", 6.hours.seconds, object_uri)
    else
      RemoveStatusService.new.call(status)
    end
  end
end
