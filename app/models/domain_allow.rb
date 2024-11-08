# frozen_string_literal: true

class DomainAllow < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include DomainMaterializable

  validates :domain, presence: true, uniqueness: true, domain: true

  def to_log_human_identifier
    domain
  end

  class << self
    def allowed?(domain)
      !rule_for(domain).nil?
    end

    def allowed_domains
      select(:domain)
    end

    def rule_for(domain)
      return if domain.blank?

      uri = Addressable::URI.new.tap { |u| u.host = domain.delete('/') }

      find_by(domain: uri.normalized_host)
    end
  end
end
