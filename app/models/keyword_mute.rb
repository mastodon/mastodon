# frozen_string_literal: true
# == Schema Information
#
# Table name: keyword_mutes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  keyword    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class KeywordMute < ApplicationRecord
  belongs_to :account, required: true

  validates_presence_of :keyword

  def self.matcher_for(account)
    Rails.cache.fetch("keyword_mutes:matcher:#{account}") { Matcher.new(account) }
  end

  class Matcher
    attr_reader :regex

    def initialize(account)
      re = String.new.tap do |str|
        scoped = KeywordMute.where(account: account)
        keywords = scoped.select(:id, :keyword)
        count = scoped.count

        keywords.find_each.with_index do |kw, index|
          str << Regexp.escape(kw.keyword.strip)
          str << '|' if index < count - 1
        end
      end

      @regex = /\b(?:#{re})\b/i unless re.empty?
    end

    def =~(str)
      regex ? regex =~ str : false
    end
  end
end
