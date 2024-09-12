# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content-Security-Policy' do
  before { allow(SecureRandom).to receive(:base64).with(16).and_return('ZbA+JmE7+bK8F5qvADZHuQ==') }

  it 'sets the expected CSP headers' do
    get '/'

    expect(response_csp_headers)
      .to match_array(expected_csp_headers)
  end

  def response_csp_headers
    response
      .headers['Content-Security-Policy']
      .split(';')
      .map(&:strip)
  end

  def expected_csp_headers
    <<~CSP.split("\n").map(&:strip)
      base-uri 'none'
      child-src 'self' blob: https://cb6e6126.ngrok.io
      connect-src 'self' data: blob: https://cb6e6126.ngrok.io #{Rails.configuration.x.streaming_api_base_url}
      default-src 'none'
      font-src 'self' https://cb6e6126.ngrok.io
      form-action 'none'
      frame-ancestors 'none'
      frame-src 'self' https:
      img-src 'self' data: blob: https://cb6e6126.ngrok.io
      manifest-src 'self' https://cb6e6126.ngrok.io
      media-src 'self' data: https://cb6e6126.ngrok.io
      script-src 'self' https://cb6e6126.ngrok.io 'wasm-unsafe-eval'
      style-src 'self' https://cb6e6126.ngrok.io 'nonce-ZbA+JmE7+bK8F5qvADZHuQ=='
      worker-src 'self' blob: https://cb6e6126.ngrok.io
    CSP
  end
end
