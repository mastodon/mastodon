# frozen_string_literal: true

class OStatus::Activity::Remote < OStatus::Activity::Base
  def perform
    find_status(id) || FetchRemoteStatusService.new.call(url)
  end
end
