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

  validates :name, presence: true, uniqueness: true, format: { with: /\A(#{HASHTAG_NAME_RE})\z/i }

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
    def search_for(term, limit = 5, offset = 0)
      pattern = sanitize_sql_like(term.strip) + '%'

      Tag.where('lower(name) like lower(?)', pattern)
         .order(:name)
         .limit(limit)
         .offset(offset)
    end

    def find_normalized(name)
      find_by(name: name.mb_chars.downcase.to_s)
    end

    def find_normalized!(name)
      find_normalized(name) || raise(ActiveRecord::RecordNotFound)
    end
  end

  private

  def save_account_tag_stat
    return unless account_tag_stat&.changed?
    account_tag_stat.save
  end
end
