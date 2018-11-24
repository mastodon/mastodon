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
#

class AccountStat < ApplicationRecord
  belongs_to :account, inverse_of: :account_stat

  def increment_count!(key)
    update(key => public_send(key) + 1)
  end

  def decrement_count!(key)
    update(key => [public_send(key) - 1, 0].max)
  end
end
