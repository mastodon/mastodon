# frozen_string_literal: true

class ActivityPub::FetchRemoteStatusService < BaseService
  include JsonLdHelper

  # Should be called when uri has already been checked for locality
  def call(uri)
    @json = fetch_resource(uri)

    return unless supported_context? && expected_type?

    attributed_to = first_of_value(@json['attributedTo'])
    attributed_to = attributed_to['id'] if attributed_to.is_a?(Hash)

    return unless trustworthy_attribution?(uri, attributed_to)

    actor = ActivityPub::TagManager.instance.uri_to_resource(attributed_to, Account)
    actor = ActivityPub::FetchRemoteAccountService.new.call(attributed_to) if actor.nil?

    ActivityPub::Activity::Create.new({ 'object' => @json }, actor).perform
  end

  private

  def trustworthy_attribution?(uri, attributed_to)
    Addressable::URI.parse(uri).normalized_host.casecmp(Addressable::URI.parse(attributed_to).normalized_host).zero?
  end

  def supported_context?
    super(@json)
  end

  def expected_type?
    %w(Note Article).include? @json['type']
  end
end
