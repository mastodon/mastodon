# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id                  :bigint(8)        not null, primary key
#  name                :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  usable              :boolean
#  trendable           :boolean
#  listable            :boolean
#  reviewed_at         :datetime
#  requested_review_at :datetime
#  last_status_at      :datetime
#  max_score           :float
#  max_score_at        :datetime
#

class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :sample_accounts, -> { local.discoverable.popular.limit(3) }, class_name: 'Account'

  has_many :featured_tags, dependent: :destroy, inverse_of: :tag
  has_one :account_tag_stat, dependent: :destroy

  HASHTAG_SEPARATORS = "_\u00B7\u200c"
  HASHTAG_NAME_RE    = "([[:word:]_][[:word:]#{HASHTAG_SEPARATORS}]*[[:alpha:]#{HASHTAG_SEPARATORS}][[:word:]#{HASHTAG_SEPARATORS}]*[[:word:]_])|([[:word:]_]*[[:alpha:]][[:word:]_]*)"
  HASHTAG_RE         = /(?:^|[^\/\)\w])#(#{HASHTAG_NAME_RE})/i

  validates :name, presence: true, format: { with: /\A(#{HASHTAG_NAME_RE})\z/i }
  validate :validate_name_change, if: -> { !new_record? && name_changed? }

  scope :reviewed, -> { where.not(reviewed_at: nil) }
  scope :unreviewed, -> { where(reviewed_at: nil) }
  scope :pending_review, -> { unreviewed.where.not(requested_review_at: nil) }
  scope :usable, -> { where(usable: [true, nil]) }
  scope :listable, -> { where(listable: [true, nil]) }
  scope :trendable, -> { Setting.trendable_by_default ? where(trendable: [true, nil]) : where(trendable: true) }
  scope :discoverable, -> { listable.joins(:account_tag_stat).where(AccountTagStat.arel_table[:accounts_count].gt(0)).order(Arel.sql('account_tag_stats.accounts_count desc')) }
  scope :most_used, ->(account) { joins(:statuses).where(statuses: { account: account }).group(:id).order(Arel.sql('count(*) desc')) }
  scope :matches_name, ->(value) { where(arel_table[:name].matches("#{value}%")) }

  delegate :accounts_count,
           :accounts_count=,
           :increment_count!,
           :decrement_count!,
           to: :account_tag_stat

  after_save :save_account_tag_stat

  update_index('tags#tag', :self)

  def account_tag_stat
    super || build_account_tag_stat
  end

  def cached_sample_accounts
    Rails.cache.fetch("#{cache_key}/sample_accounts", expires_in: 12.hours) { sample_accounts }
  end

  def to_param
    name
  end

  def usable
    boolean_with_default('usable', true)
  end

  alias usable? usable

  def listable
    boolean_with_default('listable', true)
  end

  alias listable? listable

  def trendable
    boolean_with_default('trendable', Setting.trendable_by_default)
  end

  alias trendable? trendable

  def requires_review?
    reviewed_at.nil?
  end

  def reviewed?
    reviewed_at.present?
  end

  def requested_review?
    requested_review_at.present?
  end

  def trending?
    TrendingTags.trending?(self)
  end

  def history
    days = []

    7.times do |i|
      day = i.days.ago.beginning_of_day.to_i

      days << {
        day: day.to_s,
        uses: Redis.current.get("activity:tags:#{id}:#{day}") || '0',
        accounts: Redis.current.pfcount("activity:tags:#{id}:#{day}:accounts").to_s,
      }
    end

    days
  end

  class << self
    def find_or_create_by_names(name_or_names)
      Array(name_or_names).map(&method(:normalize)).uniq { |str| str.mb_chars.downcase.to_s }.map do |normalized_name|
        tag = matching_name(normalized_name).first || create!(name: normalized_name)

        yield tag if block_given?

        tag
      end
    end

    def search_for(term, limit = 5, offset = 0, options = {})
      normalized_term = normalize(term.strip).mb_chars.downcase.to_s
      pattern         = sanitize_sql_like(normalized_term) + '%'
      query           = Tag.listable.where(arel_table[:name].lower.matches(pattern))
      query           = query.where(arel_table[:name].lower.eq(normalized_term).or(arel_table[:reviewed_at].not_eq(nil))) if options[:exclude_unreviewed]

      query.order(Arel.sql('length(name) ASC, name ASC'))
           .limit(limit)
           .offset(offset)
    end

    def find_normalized(name)
      matching_name(name).first
    end

    def find_normalized!(name)
      find_normalized(name) || raise(ActiveRecord::RecordNotFound)
    end

    def matching_name(name_or_names)
      names = Array(name_or_names).map { |name| normalize(name).mb_chars.downcase.to_s }

      if names.size == 1
        where(arel_table[:name].lower.eq(names.first))
      else
        where(arel_table[:name].lower.in(names))
      end
    end

    private

    def normalize(str)
      str.gsub(/\A#/, '')
    end
  end

  private

  def save_account_tag_stat
    return unless account_tag_stat&.changed?
    account_tag_stat.save
  end

  def validate_name_change
    errors.add(:name, I18n.t('tags.does_not_match_previous_name')) unless name_was.mb_chars.casecmp(name.mb_chars).zero?
  end
end
