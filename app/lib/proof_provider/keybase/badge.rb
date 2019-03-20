# frozen_string_literal: true

class ProofProvider::Keybase::Badge
  include RoutingHelper

  def initialize(local_username, provider_username, token)
    @local_username    = local_username
    @provider_username = provider_username
    @token             = token
  end

  def proof_url
    "#{ProofProvider::Keybase::BASE_URL}/#{@provider_username}/sigchain\##{@token}"
  end

  def profile_url
    "#{ProofProvider::Keybase::BASE_URL}/#{@provider_username}"
  end

  def icon_url
    "#{ProofProvider::Keybase::BASE_URL}/#{@provider_username}/proof_badge/#{@token}?username=#{@local_username}&domain=#{domain}"
  end

  def avatar_url
    Rails.cache.fetch("proof_providers/keybase/#{@provider_username}/avatar_url", expires_in: 5.minutes) { remote_avatar_url } || default_avatar_url
  end

  private

  def remote_avatar_url
    request = Request.new(:get, "#{ProofProvider::Keybase::BASE_URL}/_/api/1.0/user/pic_url.json", params: { username: @provider_username })

    request.perform do |res|
      json = Oj.load(res.body_with_limit, mode: :strict)
      json['pic_url'] if json.is_a?(Hash)
    end
  rescue Oj::ParseError, HTTP::Error, OpenSSL::SSL::SSLError
    nil
  end

  def default_avatar_url
    asset_pack_path('media/images/proof_providers/keybase.png')
  end

  def domain
    Rails.configuration.x.local_domain
  end
end
