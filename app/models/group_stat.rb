# frozen_string_literal: true
# == Schema Information
#
# Table name: group_stats
#
#  id             :bigint(8)        not null, primary key
#  group_id       :bigint(8)        not null
#  statuses_count :bigint(8)        default(0), not null
#  members_count  :bigint(8)        default(0), not null
#  last_status_at :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class GroupStat < ApplicationRecord
  belongs_to :group, inverse_of: :group_stat

  def members_count
    [attributes['members_count'], 0].max
  end

  def statuses_count
    [attributes['statuses_count'], 0].max
  end
end
