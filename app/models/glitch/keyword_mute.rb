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

  class RegexpMatcher
    attr_reader :account_id
    attr_reader :regex

    def initialize(account_id)
      @account_id = account_id
      regex_text = Rails.cache.fetch(self.class.cache_key(account_id)) { make_regex_text }
      @regex = /#{regex_text}/
    end

    protected

    def keywords
      Glitch::KeywordMute.where(account_id: account_id).pluck(:whole_word, :keyword)
    end

    def boundary_regex_for_keyword(keyword)
      sb = keyword =~ /\A[[:word:]]/ ? '\b' : ''
      eb = keyword =~ /[[:word:]]\Z/ ? '\b' : ''

      /(?mix:#{sb}#{Regexp.escape(keyword)}#{eb})/
    end
  end

  class TextMatcher < RegexpMatcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:text:%s', account_id)
    end

    def matches?(str)
      !!(regex =~ str)
    end

    private

    def make_regex_text
      kws = keywords.map! do |whole_word, keyword|
        whole_word ? boundary_regex_for_keyword(keyword) : keyword
      end

      Regexp.union(kws).source
    end
  end

  class TagMatcher < RegexpMatcher
    def self.cache_key(account_id)
      format('keyword_mutes:regex:tag:%s', account_id)
    end

    def matches?(tags)
      tags.pluck(:name).any? { |n| regex =~ n }
    end

    private

    def make_regex_text
      kws = keywords.map! do |whole_word, keyword|
        term = (Tag::HASHTAG_RE =~ keyword) ? $1 : keyword
        whole_word ? boundary_regex_for_keyword(term) : term
      end

      Regexp.union(kws).source
    end
  end
end
