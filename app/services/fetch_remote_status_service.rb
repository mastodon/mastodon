# frozen_string_literal: true

class FetchRemoteStatusService < BaseService
  def call(url, prefetched_body: nil, request_id: nil, on_behalf_of: nil)
    on_behalf_of = Account.find(on_behalf_of) unless on_behalf_of.nil? || on_behalf_of.is_a?(Account)

    if prefetched_body.nil?
      resource_url, resource_options = FetchResourceService.new.call(url)
    else
      resource_url     = url
      resource_options = { prefetched_body: prefetched_body }
    end

    ActivityPub::FetchRemoteStatusService.new.call(resource_url, **resource_options.merge(request_id: request_id, on_behalf_of: on_behalf_of)) unless resource_url.nil?
  end
end
