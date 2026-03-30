# frozen_string_literal: true

class ActivityPub::Dereferencer
  include JsonLdHelper

  def initialize(uri, permitted_origin: nil, signature_actor: nil)
    @uri               = uri
    @permitted_origin  = permitted_origin
    @signature_actor = signature_actor
  end

  def object
    @object ||= fetch_object!
  end

  private

  def bear_cap?
    @uri.start_with?('bear:')
  end

  def fetch_object!
    if bear_cap?
      fetch_with_token!
    else
      fetch_with_signature!
    end
  end

  def fetch_with_token!
    perform_request(bear_cap['u'], headers: { 'Authorization' => "Bearer #{bear_cap['t']}" })
  end

  def fetch_with_signature!
    perform_request(@uri)
  end

  def bear_cap
    @bear_cap ||= Addressable::URI.parse(@uri).query_values
  end

  def perform_request(uri, headers: nil)
    return if non_matching_uri_hosts?(@permitted_origin, uri)

    req = Request.new(:get, uri)

    req.add_headers('Accept' => 'application/ld+json; profile="https://www.w3.org/ns/activitystreams", application/activity+json')
    req.add_headers(headers) if headers
    req.on_behalf_of(@signature_actor) if @signature_actor

    req.perform do |res|
      if res.code == 200
        json = body_to_json(res.body_with_limit)
        json if json.present? && json['id'] == uri
      else
        raise Mastodon::UnexpectedResponseError, res unless response_successful?(res) || response_error_unsalvageable?(res)
      end
    end
  end
end
