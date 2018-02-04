# frozen_string_literal: true

class OStatus::Activity::Deletion < OStatus::Activity::Base
  def perform
    Rails.logger.debug "Deleting remote status #{id}"
    status = Status.find_by(uri: id, account: @account)

    if status.nil?
      redis.setex("delete_upon_arrival:#{@account.id}:#{id}", 6 * 3_600, id)
    else
      RemoveStatusService.new.call(status)
    end
  end
end
