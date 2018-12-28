module Keybase
  class Proof
    def initialize(kb_username, local_username, token, domain=nil)
      @kb_username = kb_username
      @local_username = local_username
      @token = token
      @domain = domain or Keybase.local_domain
    end

    def is_remote_valid?
      @is_remote_valid ||= fetch_proof_valid_from_keybase
    rescue KeyError
      false
    end

    def is_remote_live?
      @is_remote_live ||= fetch_proof_live_from_keybase
    rescue KeyError
      false
    end

    private

    def fetch_proof_valid_from_keybase
      uri = uri_for('/_/api/1.0/sig/proof_valid.json')
      Request.new(:get, uri.to_s).perform do |response|
        as_hash = JSON.parse(response.body, symbolize_names: true)
        as_hash.fetch(:proof_valid)
      end
    end

    def fetch_proof_live_from_keybase
      uri = uri_for('/_/api/1.0/sig/proof_live.json')
      Request.new(:get, uri.to_s).perform do |response|
        as_hash = JSON.parse(response.body, symbolize_names: true)
        as_hash.fetch(:proof_live)
      end
    end

    def uri_for(endpoint)
      uri = URI.parse(Keybase.base_url + endpoint)
      query_params = {
        domain: @domain,
        kb_username: @kb_username,
        username: @local_username,
        sig_hash: @token
      }
      uri.query = URI.encode_www_form(query_params)
      uri
    end
  end
end
