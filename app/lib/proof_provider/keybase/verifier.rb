# frozen_string_literal: true

class ProofProvider::Keybase::Verifier
  def initialize(local_username, provider_username, token, domain)
    @local_username    = local_username
    @provider_username = provider_username
    @token             = token
    @domain            = domain
  end

  def valid?
    request = Request.new(:get, "#{ProofProvider::Keybase::BASE_URL}/_/api/1.0/sig/proof_valid.json", params: query_params)

    request.perform do |res|
      json = Oj.load(res.body_with_limit, mode: :strict)

      if json.is_a?(Hash)
        json.fetch('proof_valid', false)
      else
        false
      end
    end
  rescue Oj::ParseError, HTTP::Error, OpenSSL::SSL::SSLError
    false
  end

  def on_success_path(user_agent = nil)
    url = Addressable::URI.parse("#{ProofProvider::Keybase::BASE_URL}/_/proof_creation_success")
    url.query_values = query_params.merge(kb_ua: user_agent || 'unknown')
    url.to_s
  end

  def status
    request = Request.new(:get, "#{ProofProvider::Keybase::BASE_URL}/_/api/1.0/sig/proof_live.json", params: query_params)

    request.perform do |res|
      raise ProofProvider::Keybase::UnexpectedResponseError unless res.code == 200

      json = Oj.load(res.body_with_limit, mode: :strict)

      raise ProofProvider::Keybase::UnexpectedResponseError unless json.is_a?(Hash) && json.key?('proof_valid') && json.key?('proof_live')

      json
    end
  rescue Oj::ParseError, HTTP::Error, OpenSSL::SSL::SSLError
    raise ProofProvider::Keybase::UnexpectedResponseError
  end

  private

  def query_params
    {
      domain: @domain,
      kb_username: @provider_username,
      username: @local_username,
      sig_hash: @token,
    }
  end
end
