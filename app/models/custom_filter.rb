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
  ).freeze

  include Expireable

  belongs_to :account

  validates :phrase, :context, presence: true
  validate :context_must_be_valid
  validate :irreversible_must_be_within_context

  scope :active_irreversible, -> { where(irreversible: true).where(Arel.sql('expires_at IS NULL OR expires_at > NOW()')) }

  before_validation :clean_up_contexts
  after_commit :remove_cache

  private

  def clean_up_contexts
    self.context = Array(context).map(&:strip).map(&:presence).compact
  end

  def remove_cache
    Rails.cache.delete("filters:#{account_id}")
    Redis.current.publish("timeline:#{account_id}", Oj.dump(event: :filters_changed))
  end

  def context_must_be_valid
    errors.add(:context, I18n.t('filters.errors.invalid_context')) if context.empty? || context.any? { |c| !VALID_CONTEXTS.include?(c) }
  end

  def irreversible_must_be_within_context
    errors.add(:irreversible, I18n.t('filters.errors.invalid_irreversible')) if irreversible? && !context.include?('home') && !context.include?('notifications')
  end
end
