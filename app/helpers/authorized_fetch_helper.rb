# frozen_string_literal: true

module AuthorizedFetchHelper
  def authorized_fetch_mode
    case ENV.fetch('AUTHORIZED_FETCH') { Setting.authorized_fetch }
    when true, 'true', 'all'
      'all'
    when 'actors'
      'actors'
    else
      'none'
    end
  end

  def authorized_fetch_mode?
    authorized_fetch_mode == 'all' || Rails.configuration.x.mastodon.limited_federation_mode
  end

  def actors_require_signature?
    Mastodon::Feature.bloom_filters_enabled? || %w(actors all).include?(authorized_fetch_mode) || Rails.configuration.x.mastodon.limited_federation_mode
  end

  def authorized_fetch_overridden?
    ENV.key?('AUTHORIZED_FETCH') || Rails.configuration.x.mastodon.limited_federation_mode
  end
end
