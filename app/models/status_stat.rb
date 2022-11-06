# frozen_string_literal: true
# == Schema Information
#
# Table name: status_stats
#
#  id               :bigint(8)        not null, primary key
#  status_id        :bigint(8)        not null
#  replies_count    :bigint(8)        default(0), not null
#  reblogs_count    :bigint(8)        default(0), not null
#  favourites_count :bigint(8)        default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class StatusStat < ApplicationRecord
  belongs_to :status, inverse_of: :status_stat

  after_commit :reset_parent_cache

  def replies_count
    replies_count = attributes['replies_count']

    if replies_count.positive?
      replies_count
    else
      0
    end
  end

  def reblogs_count
    reblogs_count = attributes['reblogs_count']

    if reblogs_count.positive?
      reblogs_count
    else
      0
    end
  end

  def favourites_count
    favourites_count = attributes['favourites_count']

    if favourites_count.positive?
      favourites_count
    else
      0
    end
  end

  private

  def reset_parent_cache
    Rails.cache.delete("statuses/#{status_id}")
  end
end
