# frozen_string_literal: true

class Ostatus::Activity::Remote < Ostatus::Activity::Base
  def perform
    find_status(id) || FetchRemoteStatusService.new.call(url)
  end
end
