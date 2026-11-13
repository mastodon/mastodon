# frozen_string_literal: true

class ActivityPub::FetchRelayService < BaseService
  include JsonLdHelper

  SUPPORTED_TYPES = %w(
    Application
    Service
  ).freeze

  class Error < StandardError; end

  def call(relay)
    relay.account = ResolveAccountService.new.call(relay.acct, suppress_errors: true)

    raise Error, 'Could not resolve relay actor from handle' if relay.account.nil?
    raise Error, "Unsupported actor type, must be one of: #{SUPPORTED_TYPES.join(', ')}" unless equals_or_includes_any?(relay.account.actor_type, SUPPORTED_TYPES)

    relay.uri = relay.account.uri
    relay.inbox_url = relay.account.inbox_url
  end
end
