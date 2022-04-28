# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_filters
#
#  id           :bigint(8)        not null, primary key
#  account_id   :bigint(8)
#  expires_at   :datetime
#  phrase       :text             default(""), not null
#  context      :string           default([]), not null, is an Array
#  whole_word   :boolean          default(TRUE), not null
#  irreversible :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CustomFilter < ApplicationRecord
  VALID_CONTEXTS = %w(
    home
    notifications
    public
    thread
    account
  ).freeze

  include Expireable
  include Redisable

  belongs_to :account

  validates :phrase, :context, presence: true
  validate :context_must_be_valid
  validate :irreversible_must_be_within_context

  scope :active_irreversible, -> { where(irreversible: true).where(Arel.sql('expires_at IS NULL OR expires_at > NOW()')) }

  before_validation :clean_up_contexts
  after_commit :remove_cache

  def expires_in
    return @expires_in if defined?(@expires_in)
    return nil if expires_at.nil?

    [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week].find { |expires_in| expires_in.from_now >= expires_at }
  end

  private

  def clean_up_contexts
    self.context = Array(context).map(&:strip).filter_map(&:presence)
  end

  def remove_cache
    Rails.cache.delete("filters:#{account_id}")
    redis.publish("timeline:#{account_id}", Oj.dump(event: :filters_changed))
  end

  def context_must_be_valid
    errors.add(:context, I18n.t('filters.errors.invalid_context')) if context.empty? || context.any? { |c| !VALID_CONTEXTS.include?(c) }
  end

  def irreversible_must_be_within_context
    errors.add(:irreversible, I18n.t('filters.errors.invalid_irreversible')) if irreversible? && !context.include?('home') && !context.include?('notifications')
  end
end
