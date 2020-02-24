# frozen_string_literal: true

class ActivityPub::FetchRemotePollService < BaseService
  include JsonLdHelper

  def call(poll, on_behalf_of = nil)
    json = fetch_resource(poll.status.uri, true, on_behalf_of)
    return unless supported_context?(json)
    ActivityPub::ProcessPollService.new.call(poll, json)
  end
end
