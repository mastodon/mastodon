# frozen_string_literal: true

class AllowDomainService < BaseService
  def call(domain)
    if DomainWhitelist.enabled?
      domain = DomainWhitelist.where(domain: domain).first
      if domain.nil?
        return :suspend
      end
      return domain.severity
    else
      domain = DomainBlock.where(domain: domain).first
      if domain.nil?
        return :enable
      end
      return domain.severity
    end
  end

  def blocked?(domain)
    return self.call(domain) == :suspend
  end

  def reject_media?(domain)
    record_type = if DomainWhitelist.enabled? then DomainWhitelist else DomainBlock end
    return record_type.find_by(domain: domain)&.reject_media?
  end
end
