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
  belongs_to :account, inverse_of: :account_stat

  def increment_count!(key)
    update(attributes_for_increment(key))
  end

  def decrement_count!(key)
    update(key => [public_send(key) - 1, 0].max)
  end

  private

  def attributes_for_increment(key)
    attrs = { key => public_send(key) + 1 }
    attrs[:last_status_at] = Time.now.utc if key == :statuses_count
    attrs
  end
end
