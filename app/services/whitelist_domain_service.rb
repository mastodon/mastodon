# frozen_string_literal: true

class WhitelistDomainService < BaseService
  def self.call(domain, severity)
    d = DomainWhitelist.where(domain: domain).first_or_create!(domain: domain, severity: severity)
    d.severity = severity
    d.save!

    if severity == :silence
      Account.where(domain: domain).update_all(silenced: true)
    elsif severity == :enable
      Account.where(:domain => domain).update_all(suspended: false)
    end
  end
end
