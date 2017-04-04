# frozen_string_literal: true

class WhitelistDomainService < BaseService
  def call(domain, severity)
    DomainWhitelist.where(domain: domain).first_or_create!(domain: domain, severity: severity)

    if severity == :silence
      Account.where(domain: domain).update_all(silenced: true)
    end
  end
end
