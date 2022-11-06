# frozen_string_literal: true
# == Schema Information
#
# Table name: account_stats
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)        not null
#  statuses_count  :bigint(8)        default(0), not null
#  following_count :bigint(8)        default(0), not null
#  followers_count :bigint(8)        default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  last_status_at  :datetime
#

class AccountStat < ApplicationRecord
  self.locking_column = nil
  self.ignored_columns = %w(lock_version)

  belongs_to :account, inverse_of: :account_stat

  update_index('accounts', :account)

  def following_count
    following_count = attributes['following_count']

    if following_count > 0
      following_count
    else
      0
    end
  end

  def followers_count
    followers_count = attributes['followers_count']

    if followers_count > 0
      followers_count
    else
      0
    end
  end

  def statuses_count
    statuses_count = attributes['statuses_count']

    if statuses_count > 0
      statuses_count
    else
      0
    end
  end
end
