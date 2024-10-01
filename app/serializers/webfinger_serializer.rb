# frozen_string_literal: true

class WebfingerSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :subject, :aliases, :links

  def subject
    object.to_webfinger_s
  end

  def aliases
    if object.instance_actor?
      [instance_actor_url]
    else
      [short_account_url(object), account_url(object)]
    end
  end

  def links
    [
      { rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: profile_page_href },
      { rel: 'self', type: 'application/activity+json', href: self_href },
      { rel: 'http://ostatus.org/schema/1.0/subscribe', template: "#{authorize_interaction_url}?uri={uri}" },
    ].tap do |x|
      x << { rel: 'http://webfinger.net/rel/avatar', type: object.avatar.content_type, href: full_asset_url(object.avatar_original_url) } if show_avatar?
    end
  end

  private

  def show_avatar?
    media_present = object.avatar.present? && object.avatar.content_type.present?

    # Show avatar only if an instance shows profiles to logged out users
    allowed_by_config = ENV['DISALLOW_UNAUTHENTICATED_API_ACCESS'] != 'true' && !Rails.configuration.x.limited_federation_mode

    media_present && allowed_by_config
  end

  def profile_page_href
    object.instance_actor? ? about_more_url(instance_actor: true) : short_account_url(object)
  end

  def self_href
    object.instance_actor? ? instance_actor_url : account_url(object)
  end
end
