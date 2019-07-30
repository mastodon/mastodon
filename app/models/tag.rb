# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses
  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :sample_accounts, -> { searchable.discoverable.popular.limit(3) }, class_name: 'Account'

  has_many :featured_tags, dependent: :destroy, inverse_of: :tag
  has_one :account_tag_stat, dependent: :destroy

  HASHTAG_NAME_RE = '([[:word:]_][[:word:]_·]*[[:alpha:]_·][[:word:]_·]*[[:word:]_])|([[:word:]_]*[[:alpha:]][[:word:]_]*)'
  HASHTAG_RE = /(?:^|[^\/\)\w])#(#{HASHTAG_NAME_RE})/i

  validates :name, presence: true, format: { with: /\A(#{HASHTAG_NAME_RE})\z/i }

  scope :discoverable, -> { joins(:account_tag_stat).where(AccountTagStat.arel_table[:accounts_count].gt(0)).where(account_tag_stats: { hidden: false }).order(Arel.sql('account_tag_stats.accounts_count desc')) }
  scope :hidden, -> { where(account_tag_stats: { hidden: true }) }
  scope :most_used, ->(account) { joins(:statuses).where(statuses: { account: account }).group(:id).order(Arel.sql('count(*) desc')) }

  delegate :accounts_count,
           :accounts_count=,
           :increment_count!,
           :decrement_count!,
           :hidden?,
           to: :account_tag_stat

  after_save :save_account_tag_stat

  def account_tag_stat
    super || build_account_tag_stat
  end

  def cached_sample_accounts
    Rails.cache.fetch("#{cache_key}/sample_accounts", expires_in: 12.hours) { sample_accounts }
  end

  def to_param
    name
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
        tag = matching_name(normalized_name).first || create(name: normalized_name)

        yield tag if block_given?

        tag
      end
    end

    def search_for(term, limit = 5, offset = 0)
      pattern = sanitize_sql_like(normalize(term.strip)) + '%'

      Tag.where(arel_table[:name].lower.matches(pattern.mb_chars.downcase.to_s))
         .order(:name)
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
end
