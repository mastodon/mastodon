# frozen_string_literal: true
require 'uri'

class Hello::VerifiedController < ActionController::Base

  def index
    redirect_uri = URI.parse(ENV['OIDC_REDIRECT_URI'])

    issuer_url = ENV['OIDC_ISSUER']
    wallet_url = issuer_url.sub('issuer.', 'wallet.')
    wallet_verified_uri = URI.parse(wallet_url)
    wallet_verified_uri.query = URI.encode_www_form(
      URI.decode_www_form(String(wallet_verified_uri.query)) << ['server', redirect_uri.host]
    )

    redirect_to wallet_verified_uri.to_s
  end
end
