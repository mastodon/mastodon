# frozen_string_literal: true

class KeybaseConfigSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :version, :domain, :display_name, :username,
             :brand_color, :logo, :description, :prefill_url,
             :profile_url, :check_url, :check_path, :avatar_path,
             :contact

  def version
    1
  end

  def domain
    ExternalProofService.my_domain
  end

  def display_name
    ExternalProofService.my_domain_displayed
  end

  def logo
    {
      # A full-black monochrome SVG. Should look good at 16px square. Expand all texts and strokes to shapes.
      svg_black: 'https://glsk.net/wp-content/themes/glsk_minimal_en/images/mastodon.svg',
      # A full color SVG. Should look good at 32px square. Expand all texts and strokes to shapes.
      svg_full: full_asset_url(asset_pack_path('logo.svg')),
    }
  end

  def brand_color
    '#282c37'
  end

  def description
    I18n.t('about.about_mastodon_html')
  end

  def username
    { min: 1, max: 30, re: Account::USERNAME_RE_STR }
  end

  def prefill_url
    params = {
      provider: AccountIdentityProof::PROVIDER_MAP[:keybase],
      token: '%{sig_hash}',
      provider_username: '%{kb_username}',
      ua: '%{kb_ua}',
    }
    CGI::unescape(new_settings_identity_proof_url(params))
  end

  def profile_url
    CGI::unescape(short_account_url('%{username}'))
  end

  def check_url
    check_uri = Addressable::URI.parse(api_v1_keybase_proofs_url)
    check_uri.query_values = { username: '%{username}'}
    CGI::unescape(check_uri.to_s)
  end

  def check_path
    ["signatures"]
  end

  def avatar_path
    ["avatar"]
  end

  def contact
    # list of contacts for Keybase in case of issues
    Setting.keybase_contacts.split(',').map(&:strip)
  end
end
