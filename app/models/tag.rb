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
#  display_name        :string
#

class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses
  has_and_belongs_to_many :accounts

  has_many :passive_relationships, class_name: 'TagFollow', inverse_of: :tag, dependent: :destroy
  has_many :featured_tags, dependent: :destroy, inverse_of: :tag
  has_many :followers, through: :passive_relationships, source: :account

  HASHTAG_SEPARATORS = "_\u00B7\u30FB\u200c"
  HASHTAG_FIRST_SEQUENCE_CHUNK_ONE = "[[:word:]_][[:word:]#{HASHTAG_SEPARATORS}]*[[:alpha:]#{HASHTAG_SEPARATORS}]"
  HASHTAG_FIRST_SEQUENCE_CHUNK_TWO = "[[:word:]#{HASHTAG_SEPARATORS}]*[[:word:]_]"
  HASHTAG_FIRST_SEQUENCE = "(#{HASHTAG_FIRST_SEQUENCE_CHUNK_ONE}#{HASHTAG_FIRST_SEQUENCE_CHUNK_TWO})"
  HASTAG_LAST_SEQUENCE = '([[:word:]_]*[[:alpha:]][[:word:]_]*)'
  HASHTAG_NAME_PAT = "#{HASHTAG_FIRST_SEQUENCE}|#{HASTAG_LAST_SEQUENCE}"

  HASHTAG_RE = /(?:^|[^\/\)\w])#(#{HASHTAG_NAME_PAT})/i
  HASHTAG_NAME_RE = /\A(#{HASHTAG_NAME_PAT})\z/i
  HASHTAG_INVALID_CHARS_RE = /[^[:alnum:]#{HASHTAG_SEPARATORS}]/

  validates :name, presence: true, format: { with: HASHTAG_NAME_RE }
  validates :display_name, format: { with: HASHTAG_NAME_RE }
  validate :validate_name_change, if: -> { !new_record? && name_changed? }
  validate :validate_display_name_change, if: -> { !new_record? && display_name_changed? }

  scope :reviewed, -> { where.not(reviewed_at: nil) }
  scope :unreviewed, -> { where(reviewed_at: nil) }
  scope :pending_review, -> { unreviewed.where.not(requested_review_at: nil) }
  scope :usable, -> { where(usable: [true, nil]) }
  scope :listable, -> { where(listable: [true, nil]) }
  scope :trendable, -> { Setting.trendable_by_default ? where(trendable: [true, nil]) : where(trendable: true) }
  scope :not_trendable, -> { where(trendable: false) }
  scope :recently_used, ->(account) {
                          joins(:statuses)
                            .where(statuses: { id: account.statuses.select(:id).limit(1000) })
                            .group(:id).order(Arel.sql('count(*) desc'))
                        }
  scope :matches_name, ->(term) { where(arel_table[:name].lower.matches(arel_table.lower("#{sanitize_sql_like(Tag.normalize(term))}%"), nil, true)) } # Search with case-sensitive to use B-tree index

  update_index('tags', :self)

  def to_param
    name
  end

  def display_name
    attributes['display_name'] || name
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

  def requires_review_notification?
    requires_review? && !requested_review?
  end

  def decaying?
    max_score_at && max_score_at >= Trends.tags.options[:max_score_cooldown].ago && max_score_at < 1.day.ago
  end

  def history
    @history ||= Trends::History.new('tags', id)
  end

  class << self
    def find_or_create_by_names(name_or_names)
      names = Array(name_or_names).map { |str| [normalize(str), str] }.uniq(&:first)

      names.map do |(normalized_name, display_name)|
        tag = matching_name(normalized_name).first || create(name: normalized_name,
                                                             display_name: display_name.gsub(HASHTAG_INVALID_CHARS_RE, ''))

        yield tag if block_given?

        tag
      end
    end

    def search_for(term, limit = 5, offset = 0, options = {})
      stripped_term = term.strip

      query = Tag.listable.matches_name(stripped_term)
      query = query.merge(matching_name(stripped_term).or(where.not(reviewed_at: nil))) if options[:exclude_unreviewed]

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
      names = Array(name_or_names).map { |name| arel_table.lower(normalize(name)) }

      if names.size == 1
        where(arel_table[:name].lower.eq(names.first))
      else
        where(arel_table[:name].lower.in(names))
      end
    end

    def normalize(str)
      HashtagNormalizer.new.normalize(str)
    end
  end

  private

  def validate_name_change
    errors.add(:name, I18n.t('tags.does_not_match_previous_name')) unless name_was.mb_chars.casecmp(name.mb_chars).zero?
  end

  def validate_display_name_change
    unless HashtagNormalizer.new.normalize(display_name).casecmp(name.mb_chars).zero?
      errors.add(:display_name,
                 I18n.t('tags.does_not_match_previous_name'))
    end
  end
end
