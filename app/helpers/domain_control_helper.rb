# frozen_string_literal: true

module DomainControlHelper
  def domain_not_allowed?(uri_or_domain)
    return false if uri_or_domain.blank?

    domain = if uri_or_domain.include?('://')
               Addressable::URI.parse(uri_or_domain).host
             else
               uri_or_domain
             end

    if limited_federation_mode?
      !DomainAllow.allowed?(domain)
    else
      DomainBlock.blocked?(domain)
    end
  end

  def limited_federation_mode?
    Rails.configuration.x.mastodon.limited_federation_mode
  end
end
