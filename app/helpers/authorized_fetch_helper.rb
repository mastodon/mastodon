# frozen_string_literal: true

module AuthorizedFetchHelper
  def authorized_fetch_mode?
    %(true all).include?(ENV.fetch('AUTHORIZED_FETCH') { Setting.authorized_fetch ? 'true' : 'false' }) || Rails.configuration.x.mastodon.limited_federation_mode
  end

  def authorized_fetch_actors?
    %w(true all actors).include?(ENV.fetch('AUTHORIZED_FETCH') { Setting.authorized_fetch ? 'true' : 'false' }) || Rails.configuration.x.mastodon.limited_federation_mode
  end

  def authorized_fetch_overridden?
    ENV.key?('AUTHORIZED_FETCH') || Rails.configuration.x.mastodon.limited_federation_mode
  end
end
