# frozen_string_literal: true

class ActivityPub::FetchRemotePollService < BaseService
  include JsonLdHelper

  def call(poll, on_behalf_of = nil)
    json = fetch_resource(poll.status.uri, true, on_behalf_of)

    return unless supported_context?(json)

    ActivityPub::ProcessStatusUpdateService.new.call(poll.status, json)
  end
end
