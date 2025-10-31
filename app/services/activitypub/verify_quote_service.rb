# frozen_string_literal: true

class ActivityPub::VerifyQuoteService < BaseService
  include JsonLdHelper

  MAX_SYNCHRONOUS_DEPTH = 2

  # Optionally fetch quoted post, and verify the quote is authorized
  def call(quote, fetchable_quoted_uri: nil, prefetched_quoted_object: nil, prefetched_approval: nil, request_id: nil, depth: nil)
    @request_id = request_id
    @depth = depth || 0
    @quote = quote
    @fetching_error = nil

    fetch_quoted_post_if_needed!(fetchable_quoted_uri, prefetched_body: prefetched_quoted_object)
    return if quote.quoted_account&.local?
    return if fast_track_approval! || quote.approval_uri.blank?

    @json = fetch_approval_object(quote.approval_uri, prefetched_body: prefetched_approval)
    return quote.reject! if @json.nil?

    return if non_matching_uri_hosts?(quote.approval_uri, value_or_id(@json['attributedTo']))
    return unless matching_type? && matching_quote_uri?

    # Opportunistically import embedded posts if needed
    return if import_quoted_post_if_needed!(fetchable_quoted_uri) && fast_track_approval!

    # Raise an error if we failed to fetch the status
    raise @fetching_error if @quote.status.nil? && @fetching_error

    return unless matching_quoted_post? && matching_quoted_author?

    quote.accept!
  end

  private

  # FEP-044f defines rules that don't require the approval flow
  def fast_track_approval!
    return false if @quote.quoted_status_id.blank?

    # Always allow someone to quote themselves
    if @quote.account_id == @quote.quoted_account_id
      @quote.accept!

      true
    end

    false
  end

  def fetch_approval_object(uri, prefetched_body: nil)
    if prefetched_body.nil?
      fetch_resource(uri, true, @quote.account.followers.local.first, raise_on_error: :temporary)
    else
      body_to_json(prefetched_body, compare_id: uri)
    end
  end

  def matching_type?
    supported_context?(@json) && equals_or_includes?(@json['type'], 'QuoteAuthorization')
  end

  def matching_quote_uri?
    ActivityPub::TagManager.instance.uri_for(@quote.status) == value_or_id(@json['interactingObject'])
  end

  def fetch_quoted_post_if_needed!(uri, prefetched_body: nil)
    return if uri.nil? || @quote.quoted_status.present?

    status = ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
    raise Mastodon::RecursionLimitExceededError if @depth > MAX_SYNCHRONOUS_DEPTH && status.nil?

    status ||= ActivityPub::FetchRemoteStatusService.new.call(uri, on_behalf_of: @quote.account.followers.local.first, prefetched_body:, request_id: @request_id, depth: @depth + 1)

    @quote.update(quoted_status: status) if status.present? && !status.reblog?
  rescue Mastodon::RecursionLimitExceededError, Mastodon::UnexpectedResponseError, *Mastodon::HTTP_CONNECTION_ERRORS => e
    @fetching_error = e
  end

  def import_quoted_post_if_needed!(uri)
    # No need to fetch if we already have a post
    return if uri.nil? || @quote.quoted_status_id.present? || !@json['interactionTarget'].is_a?(Hash)

    # NOTE: Replacing the object's context by that of the parent activity is
    # not sound, but it's consistent with the rest of the codebase
    object = @json['interactionTarget'].merge({ '@context' => @json['@context'] })

    # It's not safe to fetch if the inlined object is cross-origin or doesn't match expectations
    return if object['id'] != uri || non_matching_uri_hosts?(@quote.approval_uri, object['id'])

    status = ActivityPub::FetchRemoteStatusService.new.call(object['id'], prefetched_body: object, on_behalf_of: @quote.account.followers.local.first, request_id: @request_id, depth: @depth)

    if status.present? && !status.reblog?
      @quote.update(quoted_status: status)
      true
    else
      false
    end
  end

  def matching_quoted_post?
    return false if @quote.quoted_status_id.blank?

    ActivityPub::TagManager.instance.uri_for(@quote.quoted_status) == value_or_id(@json['interactionTarget'])
  end

  def matching_quoted_author?
    ActivityPub::TagManager.instance.uri_for(@quote.quoted_account) == value_or_id(@json['attributedTo'])
  end
end
