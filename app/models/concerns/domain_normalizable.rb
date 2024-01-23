# frozen_string_literal: true

module DomainNormalizable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_domain

    scope :by_domain_length, -> { order(Arel.sql('CHAR_LENGTH(domain)').desc) }
  end

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain&.strip)
  rescue Addressable::URI::InvalidURIError
    errors.add(:domain, :invalid)
  end
end
