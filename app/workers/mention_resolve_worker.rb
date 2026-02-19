# frozen_string_literal: true

class MentionResolveWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 7

  def perform(status_id, uri, options = {})
    status = Status.find_by(id: status_id)
    return if status.nil?

    account = account_from_uri(uri)
    account = ActivityPub::FetchRemoteAccountService.new.call(uri, request_id: options[:request_id]) if account.nil?

    return if account.nil?

    status.mentions.upsert({ account_id: account.id, silent: false }, unique_by: %w(status_id account_id))
  rescue ActiveRecord::RecordNotFound
    # Do nothing
  rescue Mastodon::UnexpectedResponseError => e
    response = e.response

    raise(e) unless response_error_unsalvageable?(response)
  end

  private

  def account_from_uri(uri)
    ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
  end
end
