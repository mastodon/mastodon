# frozen_string_literal: true

class ActivityPub::ProcessActivityService < BaseService
  include JsonLdHelper
  include DomainControlHelper

  def call(body, actor, **options)
    @account = actor
    @json    = original_json = JSON.parse(body)
    @options = options

    return unless @json.is_a?(Hash)

    ActivityPub::OpenTelemetry.decorate_current_span(payload: @json)

    # Ideally, we should treat all ActivityPub payloads as proper JSON-LD.
    # However, some implementations do not produce valid JSON-LD, and processing JSON-LD is pretty expensive.
    # Therefore, we only process activities as JSON-LD if they make use of JSON-LD signatures.
    # The reasons are that this is a strong indication that they are valid JSON-LD documents,
    # and that Linked Data Signature verification requires JSON-LD processing to begin with.
    # Doing JSON-LD compaction early ensures we know what we are working with, and avoids
    # issues like attacks involving swapping external context documents between processing steps.
    begin
      if @json['signature'].is_a?(Hash)
        check_jsonld_limits!(@json)

        @json = compact(@json)
      end

      # Unsupported features can be aliased, so re-check after compaction
      check_jsonld_limits!(@json)
    rescue Mastodon::InvalidJsonLdError => e
      Rails.logger.debug { "JSON-LD handling for document from #{value_or_id(@json['actor'])} skipped: #{e.message}" }
      @json = original_json.without('signature')
    rescue JSON::LD::JsonLdError => e
      Rails.logger.debug { "Error when compacting JSON-LD document for #{value_or_id(@json['actor'])}: #{e.message}" }
      @json = original_json.without('signature')
    end

    return unless supported_context?(@json)

    if different_actor?
      # This has been relayed by a different account.
      # Record where it's coming from and try to verify proof of the activity.

      @options[:relayed_through_actor] = @account

      # Linked Data Signature verification
      @account = actor_from_verified_ld_signature

      # If Linked Data Signature verification failed, throw away the signature
      # as other parts of the code use its presence as an indication of whether
      # to forward the activity (don't throw away compaction though, it is still useful)
      if @account.nil?
        @json = @json.without('signature')

        # Removing the signature is safe for FEP-8b32 Object Integrity Proofs as per
        # https://codeberg.org/fediverse/fep/src/branch/main/fep/8b32/fep-8b32.md#backward-compatibility
        original_json = original_json.without('signature')
      else
        @options[:forwardable_json] = @json
      end

      # Regardless of JSON-LD verification, verify FEP-8b32 Object Integrity Proofs in order
      # to forward them.
      actor_from_verified_object_integrity_proof(original_json).tap do |signing_account|
        @account ||= signing_account

        # Keep the original JSON around (potentially without `signing_account`) to be forwarded
        # without breaking FEP-8b32 verification
        @options[:forwardable_json] = original_json if signing_account.present?
      end
    end

    return if !@account.is_a?(Account) || different_actor? || suspended_actor? || @account.local?

    activity = ActivityPub::Activity.factory(@json, @account, **@options)
    activity&.perform
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

  def actor_from_verified_ld_signature
    return unless @json['signature'].is_a?(Hash)
    return if domain_not_allowed?(@json['signature']['creator'])

    ActivityPub::LinkedDataSignature.new(@json).verify_actor!
  rescue JSON::LD::JsonLdError, RDF::WriterError => e
    Rails.logger.debug { "Could not verify LD-Signature for #{value_or_id(@json['actor'])}: #{e.message}" }
    nil
  end

  def actor_from_verified_object_integrity_proof(original_json)
    return unless original_json['proof'].present? && original_json['actor'] == @json['actor']
    return if domain_not_allowed?(@json['proof']['verificationMethod'])

    # Verification is done on the original JSON without a signature
    ActivityPub::ObjectIntegrityProof.new(original_json.without('signature')).verify_actor!
  end
end
