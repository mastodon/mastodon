# frozen_string_literal: true

module DomainNormalizable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_domain

    scope :by_domain_length, -> { order(domain_char_length.desc) }
  end

  class_methods do
    def domain_char_length
      Arel.sql(
        <<~SQL.squish
          CHAR_LENGTH(domain)
        SQL
      )
    end
  end

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain&.strip)
  rescue Addressable::URI::InvalidURIError
    errors.add(:domain, :invalid)
  end
end
