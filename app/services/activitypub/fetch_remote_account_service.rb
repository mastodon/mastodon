# frozen_string_literal: true

class ActivityPub::FetchRemoteAccountService < ActivityPub::FetchRemoteActorService
  # Does a WebFinger roundtrip on each call, unless `only_key` is true
  def call(uri, prefetched_body: nil, break_on_redirect: false, only_key: false, suppress_errors: true, request_id: nil)
    actor = super
    return actor if actor.nil? || actor.is_a?(Account)

    Rails.logger.debug { "Fetching account #{uri} failed: Expected Account, got #{actor.class.name}" }
    raise Error, "Expected Account, got #{actor.class.name}" unless suppress_errors
  end
end
