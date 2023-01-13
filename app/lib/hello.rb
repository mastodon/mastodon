# frozen_string_literal: true

class Hello
  def self.mastodon_builder_url
    issuer_url = ENV['OIDC_ISSUER']
    wallet_url = issuer_url.sub('issuer.', 'wallet.')

    mastodon_builder_url = URI.parse(wallet_url)
    mastodon_builder_url.path = '/mastodon'
    mastodon_builder_url.query = URI.encode_www_form(
      URI.decode_www_form(String(mastodon_builder_url.query)) << ['server', ENV['LOCAL_DOMAIN']]
    )

    mastodon_builder_url.to_s
  end

  def self.mastodon_builder_redirect_uri
    issuer_url = ENV['OIDC_ISSUER']
    wallet_url = issuer_url.sub('issuer.', 'wallet.')

    mastodon_builder_url = URI.parse(wallet_url)
    mastodon_builder_url.path = "/oauth/response/mastodon/#{ENV['LOCAL_DOMAIN']}"

    mastodon_builder_url.to_s
  end
end
