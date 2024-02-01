# frozen_string_literal: true

class ActivityPub::FetchRemoteKeyService < BaseService
  include JsonLdHelper

  # Returns account that owns the key
  def call(uri)
    return if uri.blank?

    @json = fetch_resource(uri, false)

    return unless supported_context?(@json) && expected_type?
    return find_account(@json['id'], @json) if person?

    @owner = fetch_resource(owner_uri, true)

    return unless supported_context?(@owner) && confirmed_owner?

    find_account(owner_uri, @owner)
  end

  private

  def find_account(uri, prefetched_body)
    account   = ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
    account ||= ActivityPub::FetchRemoteAccountService.new.call(uri, prefetched_body: prefetched_body)
    account
  end

  def expected_type?
    person? || public_key?
  end

  def person?
    equals_or_includes_any?(@json['type'], ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES)
  end

  def public_key?
    @json['publicKeyPem'].present? && @json['owner'].present?
  end

  def owner_uri
    @owner_uri ||= value_or_id(@json['owner'])
  end

  def confirmed_owner?
    equals_or_includes_any?(@owner['type'], ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES) && value_or_id(@owner['publicKey']) == @json['id']
  end
end
