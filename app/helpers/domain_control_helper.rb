# frozen_string_literal: true

module DomainControlHelper
  def domain_not_allowed?(uri_or_domain)
    return if uri_or_domain.blank?

    domain = begin
      if uri_or_domain.include?('://')
        Addressable::URI.parse(uri_or_domain).domain
      else
        uri_or_domain
      end
    end

    DomainBlock.blocked?(domain)
  end
end
