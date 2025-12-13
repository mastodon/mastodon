# frozen_string_literal: true

# == Schema Information
#
# Table name: instances
#
#  domain         :string           primary key
#  accounts_count :bigint(8)
#

class Instance < ApplicationRecord
  include DatabaseViewRecord

  self.primary_key = :domain

  attr_accessor :failure_days

  with_options foreign_key: :domain, primary_key: :domain, inverse_of: false do
    belongs_to :domain_block
    belongs_to :domain_allow
    belongs_to :unavailable_domain

    has_many :accounts, dependent: nil
    has_many :moderation_notes, class_name: 'InstanceModerationNote', dependent: :destroy
  end

  scope :searchable, -> { where.not(domain: DomainBlock.select(:domain)) }
  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }
  scope :domain_starts_with, ->(value) { where(arel_table[:domain].matches("#{sanitize_sql_like(value)}%", false, true)) }
  scope :by_domain_and_subdomains, ->(domain) { where("reverse('.' || domain) LIKE reverse(?)", "%.#{domain}") }
  scope :with_domain_follows, ->(domains) { where(domain: domains).where(domain_account_follows) }

  def self.domain_account_follows
    Arel.sql(
      <<~SQL.squish
        EXISTS (
          SELECT 1
          FROM follows
          JOIN accounts ON follows.account_id = accounts.id OR follows.target_account_id = accounts.id
          WHERE accounts.domain = instances.domain
        )
      SQL
    )
  end

  def delivery_failure_tracker
    @delivery_failure_tracker ||= DeliveryFailureTracker.new(domain)
  end

  def purgeable?
    unavailable? || domain_block&.suspend?
  end

  def unavailable?
    unavailable_domain.present?
  end

  def failing?
    failure_days.present? || unavailable?
  end

  def to_param
    domain
  end

  alias to_log_human_identifier to_param

  delegate :exhausted_deliveries_days, to: :delivery_failure_tracker

  def availability_over_days(num_days, end_date = Time.now.utc.to_date)
    failures_map    = exhausted_deliveries_days.index_with { true }
    period_end_at   = exhausted_deliveries_days.last || end_date
    period_start_at = period_end_at - num_days.days

    (period_start_at..period_end_at).map do |date|
      [date, failures_map[date]]
    end
  end
end
