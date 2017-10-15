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

  after_commit :invalidate_cached_matcher

  def self.matcher_for(account_id)
    Rails.cache.fetch("keyword_mutes:matcher:#{account_id}") { Matcher.new(account_id) }
  end

  private

  def invalidate_cached_matcher
    Rails.cache.delete("keyword_mutes:matcher:#{account_id}")
  end

  class Matcher
    attr_reader :regex

    def initialize(account_id)
      re = [].tap do |arr|
        KeywordMute.where(account_id: account_id).select(:keyword, :id).find_each do |m|
          arr << Regexp.escape(m.keyword.strip)
        end
      end.join('|')

      @regex = /\b(?:#{re})\b/i unless re.empty?
    end

    def =~(str)
      regex ? regex =~ str : false
    end
  end
end
