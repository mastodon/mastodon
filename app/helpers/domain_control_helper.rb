# frozen_string_literal: true

module DomainControlHelper
  def domain_not_allowed?(uri_or_domain)
    return if uri_or_domain.blank?

    domain = if uri_or_domain.include?('://')
               Addressable::URI.parse(uri_or_domain).host
             else
               uri_or_domain
             end

    if whitelist_mode?
      !DomainAllow.allowed?(domain)
    else
      DomainBlock.blocked?(domain)
    end
  end

  def whitelist_mode?
    Rails.configuration.x.whitelist_mode
  end
end
