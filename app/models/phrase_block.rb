# frozen_string_literal: true

# == Schema Information
#
# Table name: phrase_blocks
#
#  id          :bigint(8)        not null, primary key
#  phrase      :text             not null
#  filter_type :integer          default("text"), not null
#  whole_word  :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class PhraseBlock < ApplicationRecord
  enum filter_type: { text: 0, regexp: 1 }, _suffix: :type

  validates :phrase, presence: true
  validates :phrase, regex: true, if: :regexp_type?

  after_commit :invalidate_cache!

  def to_log_human_identifier
    if regexp_type?
      "/#{phrase}/"
    else
      phrase
    end
  end

  def to_regexp
    if regexp_type?
      /#{phrase}/i
    elsif whole_word?
      sb = /\A[[:word:]]/.match?(phrase) ? '\b' : ''
      eb = /[[:word:]]\z/.match?(phrase) ? '\b' : ''

      /(?mix:#{sb}#{Regexp.escape(phrase)}#{eb})/
    else
      /#{Regexp.escape(phrase)}/i
    end
  end

  def self.cached_regexp
    Rails.cache.fetch('phrase_blocks:regexp') do
      Regexp.union(PhraseBlock.all.to_a.map(&:to_regexp))
    end
  end

  private

  def invalidate_cache!
    Rails.cache.delete('phrase_blocks:regexp')
  end
end
