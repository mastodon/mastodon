# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Remote Interaction Helper' do
  describe 'GET /remote_interaction_helper' do
    it 'returns http success' do
      get remote_interaction_helper_path

      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          headers: include(
            'X-Frame-Options' => 'SAMEORIGIN',
            'Referrer-Policy' => 'no-referrer',
            'Content-Security-Policy' => expected_csp_headers
          )
        )
      expect(response.body)
        .to match(/remote_interaction_helper/)
    end
  end

  private

  def expected_csp_headers
    <<~CSP.squish
      default-src 'none';
      frame-ancestors 'self';
      form-action 'none';
      script-src 'self' #{local_domain} 'wasm-unsafe-eval';
      connect-src https:
    CSP
  end

  def local_domain
    root_url(host: Rails.configuration.x.local_domain).chop
  end
end
