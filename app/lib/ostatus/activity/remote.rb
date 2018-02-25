# frozen_string_literal: true

class OStatus::Activity::Remote < OStatus::Activity::Base
  def perform
    if activitypub_uri?
      find_status(activitypub_uri) || FetchRemoteStatusService.new.call(url)
    else
      find_status(id) || FetchRemoteStatusService.new.call(url)
    end
  end
end
