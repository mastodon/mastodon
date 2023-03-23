# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_filters
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
#  expires_at :datetime
#  phrase     :text             default(""), not null
#  context    :string           default([]), not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  action     :integer          default("warn"), not null
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

  enum action: { warn: 0, hide: 1 }, _suffix: :action

  belongs_to :account
  has_many :keywords, class_name: 'CustomFilterKeyword', inverse_of: :custom_filter, dependent: :destroy
  has_many :statuses, class_name: 'CustomFilterStatus', inverse_of: :custom_filter, dependent: :destroy
  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true

  validates :title, :context, presence: true
  validate :context_must_be_valid

  before_validation :clean_up_contexts

  before_save :prepare_cache_invalidation!
  before_destroy :prepare_cache_invalidation!
  after_commit :invalidate_cache!

  def expires_in
    return @expires_in if defined?(@expires_in)
    return nil if expires_at.nil?

    [30.minutes, 1.hour, 6.hours, 12.hours, 1.day, 1.week].find { |expires_in| expires_in.from_now >= expires_at }
  end

  def irreversible=(value)
    self.action = ActiveModel::Type::Boolean.new.cast(value) ? :hide : :warn
  end

  def irreversible?
    hide_action?
  end

  def self.cached_filters_for(account_id)
    active_filters = Rails.cache.fetch("filters:v3:#{account_id}") do
      filters_hash = {}

      scope = CustomFilterKeyword.includes(:custom_filter).where(custom_filter: { account_id: account_id }).where(Arel.sql('expires_at IS NULL OR expires_at > NOW()'))
      scope.to_a.group_by(&:custom_filter).each do |filter, keywords|
        keywords.map! do |keyword|
          if keyword.whole_word
            sb = /\A[[:word:]]/.match?(keyword.keyword) ? '\b' : ''
            eb = /[[:word:]]\z/.match?(keyword.keyword) ? '\b' : ''

            /(?mix:#{sb}#{Regexp.escape(keyword.keyword)}#{eb})/
          else
            /#{Regexp.escape(keyword.keyword)}/i
          end
        end

        filters_hash[filter.id] = { keywords: Regexp.union(keywords), filter: filter }
      end.to_h

      scope = CustomFilterStatus.includes(:custom_filter).where(custom_filter: { account_id: account_id }).where(Arel.sql('expires_at IS NULL OR expires_at > NOW()'))
      scope.to_a.group_by(&:custom_filter).each do |filter, statuses|
        filters_hash[filter.id] ||= { filter: filter }
        filters_hash[filter.id].merge!(status_ids: statuses.map(&:status_id))
      end

      filters_hash.values.map { |cache| [cache.delete(:filter), cache] }
    end.to_a

    active_filters.select { |custom_filter, _| !custom_filter.expired? }
  end

  def self.apply_cached_filters(cached_filters, status)
    cached_filters.filter_map do |filter, rules|
      match = rules[:keywords].match(status.proper.searchable_text) if rules[:keywords].present?
      keyword_matches = [match.to_s] unless match.nil?

      status_matches = [status.id, status.reblog_of_id].compact & rules[:status_ids] if rules[:status_ids].present?

      next if keyword_matches.blank? && status_matches.blank?

      FilterResultPresenter.new(filter: filter, keyword_matches: keyword_matches, status_matches: status_matches)
    end
  end

  def prepare_cache_invalidation!
    @should_invalidate_cache = true
  end

  def invalidate_cache!
    return unless @should_invalidate_cache

    @should_invalidate_cache = false

    Rails.cache.delete("filters:v3:#{account_id}")
    redis.publish("timeline:#{account_id}", Oj.dump(event: :filters_changed))
    redis.publish("timeline:system:#{account_id}", Oj.dump(event: :filters_changed))
  end

  private

  def clean_up_contexts
    self.context = Array(context).map(&:strip).filter_map(&:presence)
  end

  def context_must_be_valid
    errors.add(:context, I18n.t('filters.errors.invalid_context')) if context.empty? || context.any? { |c| !VALID_CONTEXTS.include?(c) }
  end
end
