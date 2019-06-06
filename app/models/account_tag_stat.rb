# frozen_string_literal: true
# == Schema Information
#
# Table name: account_tag_stats
#
#  id             :bigint(8)        not null, primary key
#  tag_id         :bigint(8)        not null
#  accounts_count :bigint(8)        default(0), not null
#  hidden         :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class AccountTagStat < ApplicationRecord
  belongs_to :tag, inverse_of: :account_tag_stat

  def increment_count!(key)
    update(key => public_send(key) + 1)
  end

  def decrement_count!(key)
    update(key => [public_send(key) - 1, 0].max)
  end
end
