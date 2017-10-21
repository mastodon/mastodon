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
        Glitch::KeywordMute.where(account_id: account_id).select(:keyword, :id, :whole_word).find_each do |m|
          boundary = m.whole_word ? '\b' : ''
          arr << "#{boundary}#{Regexp.escape(m.keyword.strip)}#{boundary}"
        end
      end.join('|')

      @regex = /#{re}/i unless re.empty?
    end

    def =~(str)
      regex ? regex =~ str : false
    end
  end
end
