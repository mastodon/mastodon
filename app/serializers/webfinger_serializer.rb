# frozen_string_literal: true

class WebfingerSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :subject, :aliases, :links

  def subject
    object.to_webfinger_s
  end

  def aliases
    [short_account_url(object), account_url(object)]
  end

  def links
    [
      { rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: short_account_url(object) },
      { rel: 'http://schemas.google.com/g/2010#updates-from', type: 'application/atom+xml', href: account_url(object, format: 'atom') },
      { rel: 'self', type: 'application/activity+json', href: account_url(object) },
      { rel: 'salmon', href: api_salmon_url(object.id) },
      { rel: 'magic-public-key', href: "data:application/magic-public-key,#{object.magic_key}" },
      { rel: 'http://ostatus.org/schema/1.0/subscribe', template: "#{authorize_follow_url}?acct={uri}" },
    ]
  end
end
