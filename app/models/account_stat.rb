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
#  lock_version    :integer          default(0), not null
#

class AccountStat < ApplicationRecord
  belongs_to :account, inverse_of: :account_stat

  update_index('accounts#account', :account)

  def increment_count!(key)
    update(attributes_for_increment(key))
  rescue ActiveRecord::StaleObjectError
    begin
      reload_with_id
    rescue ActiveRecord::RecordNotFound
      # Nothing to do
    else
      retry
    end
  end

  def decrement_count!(key)
    update(key => [public_send(key) - 1, 0].max)
  rescue ActiveRecord::StaleObjectError
    begin
      reload_with_id
    rescue ActiveRecord::RecordNotFound
      # Nothing to do
    else
      retry
    end
  end

  private

  def attributes_for_increment(key)
    attrs = { key => public_send(key) + 1 }
    attrs[:last_status_at] = Time.now.utc if key == :statuses_count
    attrs
  end

  def reload_with_id
    self.id = find_by!(account: account).id if new_record?
    reload
  end
end
