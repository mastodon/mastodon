# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_filters
#
#  id         :bigint           not null, primary key
#  account_id :bigint
#  expires_at :datetime
#  phrase     :text             default(""), not null
#  context    :string           default([]), not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  action     :integer          default(0), not null
#

class CustomFilter < ApplicationRecord
  self.ignored_columns = %w(whole_word irreversible)

  alias_attribute :title, :phrase
  alias_attribute :filter_action, :action

  VALID_CONTEXTS = %w(
    home
    notifications
    public
    thread
    account
  ).freeze

  include Expireable
  include Redisable

  enum action: [:warn, :hide], _suffix: :action

  belongs_to :account
  has_many :keywords, class_name: 'CustomFilterKeyword', foreign_key: :custom_filter_id, inverse_of: :custom_filter, dependent: :destroy
  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true

  validates :title, :context, presence: true
  validate :context_must_be_valid

  before_validation :clean_up_contexts
  after_commit :remove_cache

  def expires_in
    return @expires_in if defined?(@expires_in)
    return nil if expires_at.nil?

    [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week].find { |expires_in| expires_in.from_now >= expires_at }
  end

  def irreversible=(value)
    self.action = value ? :hide : :warn
  end

  def irreversible?
    hide_action?
  end

  private

  def clean_up_contexts
    self.context = Array(context).map(&:strip).filter_map(&:presence)
  end

  def remove_cache
    Rails.cache.delete("filters:v2:#{account_id}")
    redis.publish("timeline:#{account_id}", Oj.dump(event: :filters_changed))
  end

  def context_must_be_valid
    errors.add(:context, I18n.t('filters.errors.invalid_context')) if context.empty? || context.any? { |c| !VALID_CONTEXTS.include?(c) }
  end
end
