# frozen_string_literal: true

class AllowDomainService < BaseService
  def self.default_allow
    return :suspend if DomainWhitelist.enabled?
    :enable
  end

  def self.record_type
    if DomainWhitelist.enabled?
      DomainWhitelist
    else
      DomainBlock
    end
  end

  def self.call(domain)
    return true if domain.nil?
    domain = self.record_type.find_by(domain: domain)
    return self.default_allow if domain.nil?
    return domain.severity
  end

  def self.blocked?(domain)
    return self.call(domain) == :suspend
  end

  def self.silenced?(domain)
    sev = self.call(domain)
    return sev == :silence || sev == "silence"
  end

  def self.reject_media?(domain)
    domain = self.record_type.find_by(domain: domain)
    !domain.nil? && domain.reject_media?
  end

end
