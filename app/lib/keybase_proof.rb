# frozen_string_literal: true

module Keybase
  class Proof
    def initialize(account_identity_proof, username=nil)
      @kb_username = account_identity_proof.provider_username
      @token = account_identity_proof.token
      @account_identity_proof = account_identity_proof
      @domain = ExternalProofService.my_domain
      @base_url = ExternalProofService::Keybase.base_url
      @_local_username = username
    end

    def local_username
      # performance optimization: allow initializing with this
      # value to prevent this additional query from running
      @_local_username ||= @account_identity_proof.account.username
    end

    def valid?
      get_from_keybase(
        endpoint: '/_/api/1.0/sig/proof_valid.json',
        query_params: to_keybase_params
      ).fetch(:proof_valid)
    rescue KeyError
      false
    end

    def remote_status
      result = get_from_keybase(
        endpoint: '/_/api/1.0/sig/proof_live.json',
        query_params: to_keybase_params
      )
      { is_valid: result.fetch(:proof_valid), is_live: result.fetch(:proof_live) }
    end

    def profile_pic_url
      get_from_keybase(
        endpoint: '/_/api/1.0/user/pic_url.json',
        query_params: { username: @kb_username }
      ).fetch(:pic_url)
    rescue KeyError
      nil
    end

    def success_redirect_url(useragent)
      useragent ||= "unknown"
      params = to_keybase_params
      params[:kb_ua] = useragent
      build_url('/_/proof_creation_success', params)
    end

    def badge_pic_url
      params = { domain: @domain, username: local_username }
      build_url("/#{@kb_username}/proof_badge/#{@token}", params)
    end

    def url
      build_url("/#{@kb_username}/sigchain\##{@token}", {})
    end

    private

    def to_keybase_params
      {
        domain: @domain,
        kb_username: @kb_username,
        username: local_username,
        sig_hash: @token
      }
    end

    def get_from_keybase(endpoint:, query_params:)
      Request.new(:get, build_url(endpoint, query_params)).perform do |response|
        JSON.parse(response.body, symbolize_names: true)
      end
    end

    def build_url(endpoint, query_params)
      uri = URI.parse(@base_url + endpoint)
      uri.query = URI.encode_www_form(query_params)
      uri.to_s
    end
  end
end
