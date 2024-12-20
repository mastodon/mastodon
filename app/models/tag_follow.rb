# frozen_string_literal: true

# == Schema Information
#
# Table name: tag_follows
#
#  id         :bigint(8)        not null, primary key
#  tag_id     :bigint(8)        not null
#  account_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TagFollow < ApplicationRecord
  include RateLimitable
  include Paginable

  belongs_to :tag
  belongs_to :account

  accepts_nested_attributes_for :tag

  rate_limit by: :account, family: :follows

  scope :for_local_distribution, -> { joins(account: :user).merge(User.signed_in_recently) }
end
