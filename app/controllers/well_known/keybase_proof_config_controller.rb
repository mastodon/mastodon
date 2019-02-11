# frozen_string_literal: true

module WellKnown
  class KeybaseProofConfigController < ActionController::Base
    before_action :set_default_response_format

    def show
      # see https://keybase.io/docs/proof_integration_guide#1-config
      # specific to each mastodon instance
      @my_domain = ExternalProofService.my_domain
      @domain_display = ExternalProofService.my_domain_displayed
      @contacts = ExternalProofService::Keybase.my_contacts
      @svg_black = 'https://glsk.net/wp-content/themes/glsk_minimal_en/images/mastodon.svg'
      @svg_full = 'https://upload.wikimedia.org/wikipedia/commons/4/48/Mastodon_Logotype_%28Simple%29.svg'
      @brand_color = '#282c37'
      @description = 'Mastodon is a social network based on open web protocols and free, open-source software.'
      # valid for all mastodon instances
      @username_re = "^[a-zA-Z0-9_]+([a-zA-Z0-9_\.-]+[a-zA-Z0-9_]+)?$"
      prefill_params = 'provider=Keybase&token=%{sig_hash}&provider_username=%{kb_username}&ua=%{kb_ua}' # rubocop:disable Style/FormatStringToken
      @prefill_url = "#{new_settings_identity_proof_url}?#{prefill_params}"
      @profile_url = "#{root_url}@%{username}" # rubocop:disable Style/FormatStringToken
      @check_url = "#{api_v1_keybase_proofs_url}?username=%{username}" # rubocop:disable Style/FormatStringToken
    end

    protected

    def set_default_response_format
      request.format = :json
    end

    def build_url(base_url, query_params)
      uri = URI.parse(base_url)
      uri.query = URI.encode_www_form(query_params) unless query_params.empty?
      uri.to_s
    end
  end
end
