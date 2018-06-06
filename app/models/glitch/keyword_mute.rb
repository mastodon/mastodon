# frozen_string_literal: true
# == Schema Information
#
# Table name: glitch_keyword_mutes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  keyword    :string           not null
#  whole_word :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Glitch::KeywordMute < ApplicationRecord
  belongs_to :account, required: true

  validates_presence_of :keyword

  after_commit :invalidate_cached_matchers

  def self.text_matcher_for(account_id)
    TextMatcher.new(account_id)
  end

  def self.tag_matcher_for(account_id)
    TagMatcher.new(account_id)
  end

  private

  def invalidate_cached_matchers
    Rails.cache.delete(TextMatcher.cache_key(account_id))
    Rails.cache.delete(TagMatcher.cache_key(account_id))
  end

  class CachedKeywordMute
    attr_reader :keyword
    attr_reader :whole_word

    def initialize(keyword, whole_word)
      @keyword = keyword
      @whole_word = whole_word
    end

    def boundary_regex_for_keyword
      sb = keyword =~ /\A[[:word:]]/ ? '\b' : ''
      eb = keyword =~ /[[:word:]]\Z/ ? '\b' : ''

      /(?mix:#{sb}#{Regexp.escape(keyword)}#{eb})/
    end

    def matches?(str)
      str =~ (whole_word ? boundary_regex_for_keyword : /#{Regexp.escape(keyword)}/i)
    end
  end

  class Matcher
    attr_reader :account_id
    attr_reader :words

    def initialize(account_id)
      @account_id = account_id
      @words = Rails.cache.fetch(self.class.cache_key(account_id)) { fetch_keywords }
    end

    protected

    def fetch_keywords
      Glitch::KeywordMute.where(account_id: account_id).pluck(:whole_word, :keyword).map do |whole_word, keyword|
        CachedKeywordMute.new(transform_keyword(keyword), whole_word)
      end
    end

    def transform_keyword(keyword)
      keyword
    end
  end

  class TextMatcher < Matcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:text:%s', account_id)
    end

    def matches?(str)
      words.any? { |w| w.matches?(str) }
    end
  end

  class TagMatcher < Matcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:tag:%s', account_id)
    end

    def matches?(tags)
      tags.pluck(:name).any? do |n|
        words.any? { |w| w.matches?(n) }
      end
    end

    protected

    def transform_keyword(kw)
      Tag::HASHTAG_RE =~ kw ? $1 : kw
    end
  end
end
