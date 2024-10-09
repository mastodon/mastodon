# frozen_string_literal: true

module Account::AttributionDomains
  extend ActiveSupport::Concern

  included do
    validates :attribution_domains_as_text, domain: { multiline: true }, lines: { maximum: 100 }, if: -> { local? && will_save_change_to_attribution_domains? }
  end

  def attribution_domains_as_text
    self[:attribution_domains].join("\n")
  end

  def attribution_domains_as_text=(str)
    self[:attribution_domains] = str.split.filter_map do |line|
      line
        .strip
        .delete_prefix('http://')
        .delete_prefix('https://')
        .delete_prefix('*.')
    end
  end

  def can_be_attributed_from?(domain)
    segments = domain.split('.')
    variants = segments.map.with_index { |_, i| segments[i..].join('.') }.to_set
    self[:attribution_domains].to_set.intersect?(variants)
  end
end
