# frozen_string_literal: true

class ActivityPub::FetchRemotePollService < BaseService
  include JsonLdHelper

  def call(poll)
    json = fetch_resource(poll.status.uri, true)

    return unless supported_context?(json)

    ActivityPub::ProcessPollService.new.call(poll, json)
  end
end
