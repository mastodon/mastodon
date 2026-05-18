# frozen_string_literal: true

class ActivityPub::VerifyFeaturedItemService
  include JsonLdHelper

  def call(collection_item, approval_uri, request_id: nil)
    @collection_item = collection_item
    @authorization = fetch_resource(approval_uri, true, raise_on_error: :temporary)

    if @authorization.nil?
      @collection_item.update!(state: :rejected)
      return
    end

    return if non_matching_uri_hosts?(approval_uri, @authorization['interactionTarget'])
    return unless matching_type? && matching_collection_uri?

    account = Account.where(uri: @collection_item.object_uri).first
    account ||= ActivityPub::FetchRemoteAccountService.new.call(@collection_item.object_uri, request_id:)
    return if account.blank?

    @collection_item.update!(account:, approval_uri:, state: :accepted)
  end

  private

  def matching_type?
    supported_context?(@authorization) && equals_or_includes?(@authorization['type'], 'FeatureAuthorization')
  end

  def matching_collection_uri?
    @collection_item.collection.uri == @authorization['interactingObject']
  end
end
