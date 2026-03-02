# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_filter_keywords
#
#  id               :bigint(8)        not null, primary key
#  custom_filter_id :bigint(8)        not null
#  keyword          :text             default(""), not null
#  whole_word       :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CustomFilterKeyword < ApplicationRecord
  include CustomFilterCache

  belongs_to :custom_filter

  KEYWORD_LENGTH_LIMIT = 512

  validates :keyword, presence: true, length: { maximum: KEYWORD_LENGTH_LIMIT }

  alias_attribute :phrase, :keyword

  def to_regex
    if whole_word?
      /(?mix:#{to_regex_sb}#{Regexp.escape(keyword)}#{to_regex_eb})/
    else
      /#{Regexp.escape(keyword)}/i
    end
  end

  private

  def to_regex_sb
    /\A[[:word:]]/.match?(keyword) ? '\b' : ''
  end

  def to_regex_eb
    /[[:word:]]\z/.match?(keyword) ? '\b' : ''
  end
end
