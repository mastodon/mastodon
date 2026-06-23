# frozen_string_literal: true

class ActivityPub::ProcessCollectionService < BaseService
  include JsonLdHelper
  include DomainControlHelper

  def call(body, actor, **options)
    @account = actor
    @json    = original_json = JSON.parse(body)
    @options = options

    return unless @json.is_a?(Hash)

    # Ideally, we should treat all ActivityPub payloads as proper JSON-LD.
    # However, some implementations do not produce valid JSON-LD, and processing JSON-LD is pretty expensive.
    # Therefore, we only process activities as JSON-LD if they make use of JSON-LD signatures.
    # The reasons are that this is a strong indication that they are valid JSON-LD documents,
    # and that Linked Data Signature verification requires JSON-LD processing to begin with.
    # Doing JSON-LD compaction early ensures we know what we are working with, and avoids
    # issues like attacks involving swapping external context documents between processing steps.
    begin
      @json = compact(@json) if @json['signature'].is_a?(Hash)
      if unsupported_jsonld_features?(@json)
        Rails.logger.debug { "JSON-LD document for #{value_or_id(@json['actor'])} contains unsupported JSON-LD features" }
        @json = original_json.without('signature')
      end
    rescue JSON::LD::JsonLdError => e
      Rails.logger.debug { "Error when compacting JSON-LD document for #{value_or_id(@json['actor'])}: #{e.message}" }
      @json = original_json.without('signature')
    end

    return unless supported_context?(@json)

    if different_actor?
      # This has been relayed by a different account.
      # Record where it's coming from and try to verify proof of the activity.

      @options[:relayed_through_actor] = @account

      # TODO: handle FEP-8b32
      @account = actor_from_verified_ld_signature
    end

    return if !@account.is_a?(Account) || different_actor? || suspended_actor? || @account.local?

    if @json['signature'].present?
      # We have verified the signature, but in the compaction step above, might
      # have introduced incompatibilities with other servers that do not
      # normalize the JSON-LD documents (for instance, previous Mastodon
      # versions), so skip redistribution if we can't get a safe document.
      patch_for_forwarding!(original_json, @json)
      @json.delete('signature') unless safe_for_forwarding?(original_json, @json)
    end

    case @json['type']
    when 'Collection', 'CollectionPage'
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      process_items @json['orderedItems']
    else
      process_items [@json]
    end
  rescue JSON::ParserError
    nil
  end

  private

  def different_actor?
    @json['actor'].present? && value_or_id(@json['actor']) != @account.uri
  end

  def suspended_actor?
    @account.suspended? && !activity_allowed_while_suspended?
  end

  def activity_allowed_while_suspended?
    %w(Delete Reject Undo Update).include?(@json['type'])
  end

  def process_items(items)
    items.reverse_each.filter_map { |item| process_item(item) }
  end

  def process_item(item)
    activity = ActivityPub::Activity.factory(item, @account, **@options)
    activity&.perform
  end

  def actor_from_verified_ld_signature
    return unless @json['signature'].is_a?(Hash)
    return if domain_not_allowed?(@json['signature']['creator'])

    ActivityPub::LinkedDataSignature.new(@json).verify_actor!
  rescue JSON::LD::JsonLdError, RDF::WriterError => e
    Rails.logger.debug { "Could not verify LD-Signature for #{value_or_id(@json['actor'])}: #{e.message}" }
    nil
  end
end
