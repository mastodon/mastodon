# frozen_string_literal: true

class ProofProvider::Keybase::ConfigSerializer < ActiveModel::Serializer
  include RoutingHelper
  include ActionView::Helpers::TextHelper

  attributes :version, :domain, :display_name, :username,
             :brand_color, :logo, :description, :prefill_url,
             :profile_url, :check_url, :check_path, :avatar_path,
             :contact

  def version
    1
  end

  def domain
    ProofProvider::Keybase::DOMAIN
  end

  def display_name
    Setting.site_title
  end

  def logo
    {
      svg_black: full_asset_url(asset_pack_path('media/images/logo_transparent_black.svg')),
      svg_white: full_asset_url(asset_pack_path('media/images/logo_transparent_white.svg')),
      svg_full: full_asset_url(asset_pack_path('media/images/logo.svg')),
      svg_full_darkmode: full_asset_url(asset_pack_path('media/images/logo.svg')),
    }
  end

  def brand_color
    '#282c37'
  end

  def description
    strip_tags(Setting.site_short_description.presence || I18n.t('about.about_mastodon_html'))
  end

  def username
    { min: 1, max: 30, re: '[a-z0-9_]+([a-z0-9_.-]+[a-z0-9_]+)?' }
  end

  def prefill_url
    params = {
      provider: 'keybase',
      token: '%{sig_hash}',
      provider_username: '%{kb_username}',
      username: '%{username}',
      user_agent: '%{kb_ua}',
    }

    CGI.unescape(new_settings_identity_proof_url(params))
  end

  def profile_url
    CGI.unescape(short_account_url('%{username}')) # rubocop:disable Style/FormatStringToken
  end

  def check_url
    CGI.unescape(api_proofs_url(username: '%{username}', provider: 'keybase'))
  end

  def check_path
    ['signatures']
  end

  def avatar_path
    ['avatar']
  end

  def contact
    [Setting.site_contact_email.presence || 'unknown'].compact
  end
end
