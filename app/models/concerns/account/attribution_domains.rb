# frozen_string_literal: true

module Account::AttributionDomains
  extend ActiveSupport::Concern

  ATTRIBUTION_DOMAINS_LIMIT = 100

  included do
    normalizes :attribution_domains, with: ->(arr) { arr.filter_map { |str| str.to_s.strip.delete_prefix('http://').delete_prefix('https://').delete_prefix('*.').presence }.uniq }

    validates :attribution_domains, domain: true, length: { maximum: ATTRIBUTION_DOMAINS_LIMIT }, if: -> { local? && will_save_change_to_attribution_domains? }
  end

  def can_be_attributed_from?(domain)
    segments = domain.split('.')
    variants = segments.map.with_index { |_, i| segments[i..].join('.') }.to_set
    self[:attribution_domains].to_set.intersect?(variants)
  end
end
