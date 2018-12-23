# frozen_string_literal: true

class ActivityPub::FetchRemoteKeyService < BaseService
  include JsonLdHelper

  # Returns account that owns the key
  def call(uri, id: true, prefetched_body: nil)
    if prefetched_body.nil?
      if id
        @json = fetch_resource_without_id_validation(uri)
        if person?
          @json = fetch_resource(@json['id'], true)
        elsif uri != @json['id']
          return
        end
      else
        @json = fetch_resource(uri, id)
      end
    else
      @json = body_to_json(prefetched_body)
    end

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
    @json['type'] == 'Person'
  end

  def public_key?
    @json['publicKeyPem'].present? && @json['owner'].present?
  end

  def owner_uri
    @owner_uri ||= value_or_id(@json['owner'])
  end

  def confirmed_owner?
    @owner['type'] == 'Person' && value_or_id(@owner['publicKey']) == @json['id']
  end
end
