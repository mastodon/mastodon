# frozen_string_literal: true

class FetchRemoteAccountService < BaseService
  def call(url, prefetched_body = nil, protocol = :ostatus)
    if prefetched_body.nil?
      resource_url, resource_options, protocol = FetchResourceService.new.call(url)
    else
      resource_url     = url
      resource_options = { prefetched_body: prefetched_body }
    end

    case protocol
    when :activitypub
      ActivityPub::FetchRemoteAccountService.new.call(resource_url, **resource_options)
    end
  end
end
