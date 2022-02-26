# frozen_string_literal: true
# == Schema Information
#
# Table name: email_domain_blocks
#
#  id              :bigint(8)        not null, primary key
#  domain          :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  parent_id       :bigint(8)
#  ips             :inet             is an Array
#  last_refresh_at :datetime
#

class EmailDomainBlock < ApplicationRecord
  include DomainNormalizable

  belongs_to :parent, class_name: 'EmailDomainBlock', optional: true
  has_many :children, class_name: 'EmailDomainBlock', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  validates :domain, presence: true, uniqueness: true, domain: true

  # Used for adding multiple blocks at once
  attr_accessor :other_domains

  def history
    @history ||= Trends::History.new('email_domain_blocks', id)
  end

  def self.block?(domain_or_domains, ips: [], attempt_ip: nil)
    domains = Array(domain_or_domains).map do |str|
      domain = begin
        if str.include?('@')
          str.split('@', 2).last
        else
          str
        end
      end

      TagManager.instance.normalize_domain(domain) if domain.present?
    rescue Addressable::URI::InvalidURIError
      nil
    end

    # If some of the inputs passed in are invalid, we definitely want to
    # block the attempt, but we also want to register hits against any
    # other valid matches

    blocked = domains.any?(&:nil?)

    scope = where(domain: domains)
    scope = scope.or(where('ips && ARRAY[?]::inet[]', ips)) if ips.any?

    scope.find_each do |block|
      blocked = true
      block.history.add(attempt_ip) if attempt_ip.present?
    end

    blocked
  end
end
