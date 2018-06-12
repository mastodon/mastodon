# frozen_string_literal: true
# == Schema Information
#
# Table name: glitch_keyword_mutes
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)        not null
#  keyword           :string           not null
#  whole_word        :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  apply_to_mentions :boolean          default(TRUE), not null
#

class Glitch::KeywordMute < ApplicationRecord
  belongs_to :account, required: true

  validates_presence_of :keyword

  after_commit :invalidate_cached_matchers

  module Scopes
    Unscoped = 0b00
    HomeFeed = 0b01
    Mentions = 0b10
  end

  def self.text_matcher_for(account_id)
    TextMatcher.new(account_id)
  end

  def self.tag_matcher_for(account_id)
    TagMatcher.new(account_id)
  end

  def scope
    s = Scopes::Unscoped
    s |= Scopes::HomeFeed
    s |= Scopes::Mentions if apply_to_mentions?
    s
  end

  private

  def invalidate_cached_matchers
    Rails.cache.delete(TextMatcher.cache_key(account_id))
    Rails.cache.delete(TagMatcher.cache_key(account_id))
  end

  class CachedKeywordMute
    attr_reader :keyword
    attr_reader :whole_word
    attr_reader :scope

    def initialize(keyword, whole_word, scope)
      @keyword = keyword
      @whole_word = whole_word
      @scope = scope
    end

    def boundary_regex_for_keyword
      sb = keyword =~ /\A[[:word:]]/ ? '\b' : ''
      eb = keyword =~ /[[:word:]]\Z/ ? '\b' : ''

      /(?mix:#{sb}#{Regexp.escape(keyword)}#{eb})/
    end

    def matches?(str, required_scope)
      ((required_scope & scope) == required_scope) && \
        str =~ (whole_word ? boundary_regex_for_keyword : /#{Regexp.escape(keyword)}/i)
    end
  end

  class Matcher
    attr_reader :account_id
    attr_reader :keywords

    def initialize(account_id)
      @account_id = account_id
      @keywords = Rails.cache.fetch(self.class.cache_key(account_id)) { fetch_keywords }
    end

    protected

    def fetch_keywords
      Glitch::KeywordMute.select(:whole_word, :keyword, :apply_to_mentions)
        .where(account_id: account_id)
        .map { |kw| CachedKeywordMute.new(transform_keyword(kw.keyword), kw.whole_word, kw.scope) }
    end

    def transform_keyword(keyword)
      keyword
    end
  end

  class TextMatcher < Matcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:text:%s', account_id)
    end

    def matches?(str, scope)
      keywords.any? { |kw| kw.matches?(str, scope) }
    end
  end

  class TagMatcher < Matcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:tag:%s', account_id)
    end

    def matches?(tags, scope)
      tags.pluck(:name).any? do |n|
        keywords.any? { |kw| kw.matches?(n, scope) }
      end
    end

    protected

    def transform_keyword(kw)
      Tag::HASHTAG_RE =~ kw ? $1 : kw
    end
  end
end
