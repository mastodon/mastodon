# frozen_string_literal: true

# == Schema Information
#
# Table name: username_blocks
#
#  id                  :bigint(8)        not null, primary key
#  allow_with_approval :boolean          default(FALSE), not null
#  exact               :boolean          default(FALSE), not null
#  normalized_username :string           not null
#  username            :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class UsernameBlock < ApplicationRecord
  HOMOGLYPHS = {
    '1' => 'i',
    '2' => 'z',
    '3' => 'e',
    '4' => 'a',
    '5' => 's',
    '7' => 't',
    '8' => 'b',
    '9' => 'g',
    '0' => 'o',
  }.freeze

  validates :username, presence: true, uniqueness: true

  scope :matches_exactly, ->(str) { where(exact: true).where(normalized_username: str) }
  scope :matches_partially, ->(str) { where(exact: false).where(Arel::Nodes.build_quoted(normalize_value_for(:normalized_username, str)).matches(Arel::Nodes.build_quoted('%').concat(arel_table[:normalized_username]).concat(Arel::Nodes.build_quoted('%')))) }

  before_save :set_normalized_username

  normalizes :normalized_username, with: ->(value) { value.downcase.gsub(Regexp.union(HOMOGLYPHS.keys), HOMOGLYPHS) }

  def comparison
    exact? ? 'equals' : 'contains'
  end

  def comparison=(val)
    self.exact = val == 'equals'
  end

  def self.matches?(str, allow_with_approval: false)
    matches_exactly(str).or(matches_partially(str)).where(allow_with_approval: allow_with_approval).any?
  end

  def to_log_human_identifier
    username
  end

  private

  def set_normalized_username
    self.normalized_username = username
  end
end
