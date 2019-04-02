# frozen_string_literal: true

class InstanceWebfingerSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :subject, :aliases, :links

  def subject
    "acct:#{Rails.configuration.x.local_domain}@#{Rails.configuration.x.local_domain}"
  end

  def aliases
    [instance_actor_url]
  end

  def links
    [
      { rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: instance_actor_url },
      { rel: 'self', type: 'application/activity+json', href: instance_actor_url },
    ]
  end
end
