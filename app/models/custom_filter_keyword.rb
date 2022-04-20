# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_filter_keywords
#
#  id               :bigint           not null, primary key
#  custom_filter_id :bigint           not null
#  keyword          :text             default(""), not null
#  whole_word       :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CustomFilterKeyword < ApplicationRecord
  include Redisable

  belongs_to :custom_filter

  validates :keyword, presence: true

  alias_attribute :phrase, :keyword

  after_commit :remove_cache

  private

  def remove_cache
    account_id = custom_filter.account_id
    Rails.cache.delete("filters:v2:#{account_id}")
    redis.publish("timeline:#{account_id}", Oj.dump(event: :filters_changed))
  end
end
