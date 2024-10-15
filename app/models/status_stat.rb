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
#  emoji_count      :jsonb
#

class StatusStat < ApplicationRecord
  belongs_to :status, inverse_of: :status_stat

  def replies_count
    [attributes['replies_count'], 0].max
  end

  def reblogs_count
    [attributes['reblogs_count'], 0].max
  end

  def favourites_count
    [attributes['favourites_count'], 0].max
  end

  def emoji_count
    attributes['emoji_count'] || {}
  end
end
