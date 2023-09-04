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
  belongs_to :custom_filter

  validates :keyword, presence: true

  alias_attribute :phrase, :keyword

  before_save :prepare_cache_invalidation!
  before_destroy :prepare_cache_invalidation!
  after_commit :invalidate_cache!

  private

  def prepare_cache_invalidation!
    custom_filter.prepare_cache_invalidation!
  end

  def invalidate_cache!
    custom_filter.invalidate_cache!
  end
end
