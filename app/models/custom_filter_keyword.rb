# frozen_string_literal: true

class CustomFilterKeyword < ApplicationRecord
  include CustomFilterCache

  belongs_to :custom_filter

  validates :keyword, presence: true

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
