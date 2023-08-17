# frozen_string_literal: true

# == Schema Information
#
# Table name: poll_votes
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)
#  poll_id    :bigint(8)
#  choice     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uri        :string
#

class PollVote < ApplicationRecord
  belongs_to :account
  belongs_to :poll, inverse_of: :votes

  validates :choice, presence: true
  validates_with VoteValidator

  after_create_commit :increment_counter_cache

  delegate :local?, to: :account
  delegate :multiple?, :expired?, to: :poll, prefix: true

  def object_type
    :vote
  end

  private

  def increment_counter_cache
    poll.cached_tallies[choice] = (poll.cached_tallies[choice] || 0) + 1
    poll.save
  rescue ActiveRecord::StaleObjectError
    poll.reload
    retry
  end
end
