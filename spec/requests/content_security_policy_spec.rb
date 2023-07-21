# frozen_string_literal: true

require 'rails_helper'

describe 'Content-Security-Policy' do
  it 'sets the expected CSP headers' do
    allow(SecureRandom).to receive(:base64).with(16).and_return('ZbA+JmE7+bK8F5qvADZHuQ==')

    get '/'
    expect(response.headers['Content-Security-Policy'].split(';').map(&:strip)).to contain_exactly(
      "base-uri 'none'",
      "default-src 'none'",
      "frame-ancestors 'none'",
      "font-src 'self' https://cb6e6126.ngrok.io",
      "img-src 'self' https: data: blob: https://cb6e6126.ngrok.io",
      "style-src 'self' https://cb6e6126.ngrok.io 'nonce-ZbA+JmE7+bK8F5qvADZHuQ=='",
      "media-src 'self' https: data: https://cb6e6126.ngrok.io",
      "frame-src 'self' https:",
      "manifest-src 'self' https://cb6e6126.ngrok.io",
      "form-action 'self'",
      "child-src 'self' blob: https://cb6e6126.ngrok.io",
      "worker-src 'self' blob: https://cb6e6126.ngrok.io",
      "connect-src 'self' data: blob: https://cb6e6126.ngrok.io https://cb6e6126.ngrok.io ws://localhost:4000",
      "script-src 'self' https://cb6e6126.ngrok.io"
    )
  end
end
