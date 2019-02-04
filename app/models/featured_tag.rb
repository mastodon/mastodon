# frozen_string_literal: true
# == Schema Information
#
# Table name: featured_tags
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)
#  tag_id         :bigint(8)
#  statuses_count :bigint(8)        default(0), not null
#  last_status_at :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FeaturedTag < ApplicationRecord
  belongs_to :account, inverse_of: :featured_tags, required: true
  belongs_to :tag, inverse_of: :featured_tags, required: true

  delegate :name, to: :tag, allow_nil: true

  def name=(str)
    self.tag = Tag.find_by(name: str.delete('#').mb_chars.downcase.to_s)
  end

  def increment(timestamp)
    update(statuses_count: statuses_count + 1, last_status_at: timestamp)
  end

  def decrement(deleted_status_id)
    update(statuses_count: [0, statuses_count - 1].max, last_status_at: account.statuses.where(visibility: %i(public unlisted)).tagged_with(tag).where.not(id: deleted_status_id).select(:created_at).first&.created_at)
  end

  def reset_data
    self.statuses_count = account.statuses.where(visibility: %i(public unlisted)).tagged_with(tag).count
    self.last_status_at = account.statuses.where(visibility: %i(public unlisted)).tagged_with(tag).select(:created_at).first&.created_at
  end
end
