# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_blocks
#
#  id              :bigint(8)        not null, primary key
#  domain          :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  severity        :integer          default("silence")
#  reject_media    :boolean          default(FALSE), not null
#  reject_reports  :boolean          default(FALSE), not null
#  private_comment :text
#  public_comment  :text
#  obfuscate       :boolean          default(FALSE), not null
#

class DomainBlock < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include DomainMaterializable

  enum severity: { silence: 0, suspend: 1, noop: 2 }

  validates :domain, presence: true, uniqueness: true, domain: true

  has_many :accounts, foreign_key: :domain, primary_key: :domain, inverse_of: false
  delegate :count, to: :accounts, prefix: true

  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }
  scope :with_user_facing_limitations, -> { where(severity: [:silence, :suspend]) }
  scope :with_limitations, -> { where(severity: [:silence, :suspend]).or(where(reject_media: true)) }
  scope :by_severity, -> { order(Arel.sql('(CASE severity WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 0 END), domain')) }

  def to_log_human_identifier
    domain
  end

  def policies
    if suspend?
      [:suspend]
    else
      [severity.to_sym, reject_media? ? :reject_media : nil, reject_reports? ? :reject_reports : nil].reject { |policy| policy == :noop || policy.nil? }
    end
  end

  class << self
    def suspend?(domain)
      !!rule_for(domain)&.suspend?
    end

    def silence?(domain)
      !!rule_for(domain)&.silence?
    end

    def reject_media?(domain)
      !!rule_for(domain)&.reject_media?
    end

    def reject_reports?(domain)
      !!rule_for(domain)&.reject_reports?
    end

    alias blocked? suspend?

    def rule_for(domain)
      return if domain.blank?

      uri      = Addressable::URI.new.tap { |u| u.host = domain.strip.gsub(/[\/]/, '') }
      segments = uri.normalized_host.split('.')
      variants = segments.map.with_index { |_, i| segments[i..-1].join('.') }

      where(domain: variants).order(Arel.sql('char_length(domain) desc')).first
    rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
      nil
    end
  end

  def stricter_than?(other_block)
    return true  if suspend?
    return false if other_block.suspend? && (silence? || noop?)
    return false if other_block.silence? && noop?

    (reject_media || !other_block.reject_media) && (reject_reports || !other_block.reject_reports)
  end

  def affected_accounts_count
    scope = suspend? ? accounts.where(suspended_at: created_at) : accounts.where(silenced_at: created_at)
    scope.count
  end

  def public_domain
    return domain unless obfuscate?

    length        = domain.size
    visible_ratio = length / 4

    domain.chars.map.with_index do |chr, i|
      if i > visible_ratio && i < length - visible_ratio && chr != '.'
        '*'
      else
        chr
      end
    end.join
  end

  def domain_digest
    Digest::SHA256.hexdigest(domain)
  end
end
