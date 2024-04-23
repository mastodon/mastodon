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
  MINIMUM_COUNT = 0

  belongs_to :status, inverse_of: :status_stat

  def replies_count
    [attributes['replies_count'], MINIMUM_COUNT].max
  end

  def reblogs_count
    [attributes['reblogs_count'], MINIMUM_COUNT].max
  end

  def favourites_count
    [attributes['favourites_count'], MINIMUM_COUNT].max
  end
end
