# frozen_string_literal: true
# == Schema Information
#
# Table name: email_domain_blocks
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint(8)
#

class EmailDomainBlock < ApplicationRecord
  self.ignored_columns = %w(
    ips
    last_refresh_at
  )

  include DomainNormalizable
  include Paginable

  belongs_to :parent, class_name: 'EmailDomainBlock', optional: true
  has_many :children, class_name: 'EmailDomainBlock', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  validates :domain, presence: true, uniqueness: true, domain: true

  # Used for adding multiple blocks at once
  attr_accessor :other_domains

  def to_log_human_identifier
    domain
  end

  def history
    @history ||= Trends::History.new('email_domain_blocks', id)
  end

  class Matcher
    def initialize(domain_or_domains, attempt_ip: nil)
      @uris       = extract_uris(domain_or_domains)
      @attempt_ip = attempt_ip
    end

    def match?
      blocking? || invalid_uri?
    end

    private

    def invalid_uri?
      @uris.any?(&:nil?)
    end

    def blocking?
      blocks = EmailDomainBlock.where(domain: domains_with_variants).order(Arel.sql('char_length(domain) desc'))
      blocks.each { |block| block.history.add(@attempt_ip) } if @attempt_ip.present?
      blocks.any?
    end

    def domains_with_variants
      @uris.flat_map do |uri|
        next if uri.nil?

        segments = uri.normalized_host.split('.')

        segments.map.with_index { |_, i| segments[i..-1].join('.') }
      end
    end

    def extract_uris(domain_or_domains)
      Array(domain_or_domains).map do |str|
        domain = begin
          if str.include?('@')
            str.split('@', 2).last
          else
            str
          end
        end

        Addressable::URI.new.tap { |u| u.host = domain.strip } if domain.present?
      rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
        nil
      end
    end
  end

  def self.block?(domain_or_domains, attempt_ip: nil)
    Matcher.new(domain_or_domains, attempt_ip: attempt_ip).match?
  end
end
