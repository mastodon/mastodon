# frozen_string_literal: true

class ActivityPub::VerifyQuoteService < BaseService
  include JsonLdHelper

  def call(quote, expected_quoted_uri: nil, prefetched_body: nil)
    @quote = quote
    return if fast_track_approval! || quote.approval_uri.blank?

    @json = fetch_approval_object(quote.approval_uri, prefetched_body:)
    if @json.nil?
      # It is possible the proof isn't dereferenceable yet, so only reject if already accepted
      quote.reject! unless @quote.pending?
      return
    end

    return if non_matching_uri_hosts?(quote.approval_uri, value_or_id(@json['attributedTo']))
    return unless matching_type? && matching_quote_uri?

    # Opportunistically import embedded posts if needed
    return if import_quoted_post_if_needed!(expected_quoted_uri) && fast_track_approval!

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

    # Always allow someone to quote posts in which they are mentioned
    if @quote.quoted_status.active_mentions.exists?(mentions: { account_id: @quote.account_id })
      @quote.accept!

      true
    else
      false
    end
  end

  def fetch_approval_object(uri, prefetched_body: nil)
    if prefetched_body.nil?
      fetch_resource(uri, true, @quote.account, raise_on_error: :temporary)
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

  def import_quoted_post_if_needed!(uri)
    return if uri.nil? || @quote.quoted_status_id.present?
    return if value_or_id(@json['interactionTarget']) == uri

    status = ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
    # TODO: import embedded post

    if status.present?
      quote.update(status: status)
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
