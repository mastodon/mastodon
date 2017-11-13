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

  after_commit :invalidate_cached_matcher

  def self.matcher_for(account_id)
    Matcher.new(account_id)
  end

  private

  def invalidate_cached_matcher
    Rails.cache.delete("keyword_mutes:regex:#{account_id}")
  end

  class Matcher
    attr_reader :account_id
    attr_reader :regex

    def initialize(account_id)
      @account_id = account_id
      regex_text = Rails.cache.fetch("keyword_mutes:regex:#{account_id}") { regex_text_for_account }
      @regex = /#{regex_text}/
    end

    def =~(str)
      regex =~ str
    end

    private

    def keywords
      Glitch::KeywordMute.where(account_id: account_id).select(:keyword, :id, :whole_word)
    end

    def regex_text_for_account
      kws = keywords.find_each.with_object([]) do |kw, a|
        a << (kw.whole_word ? boundary_regex_for_keyword(kw.keyword) : kw.keyword)
      end

      Regexp.union(kws).source
    end

    def boundary_regex_for_keyword(keyword)
      sb = keyword =~ /\A[[:word:]]/ ? '\b' : ''
      eb = keyword =~ /[[:word:]]\Z/ ? '\b' : ''

      /(?mix:#{sb}#{Regexp.escape(keyword)}#{eb})/
    end
  end
end
