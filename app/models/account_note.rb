# frozen_string_literal: true

# == Schema Information
#
# Table name: account_notes
#
#  id                :bigint(8)        not null, primary key
#  comment           :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#
class AccountNote < ApplicationRecord
  include RelationshipCacheable

  COMMENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }
  validates :comment, length: { maximum: COMMENT_SIZE_LIMIT }
end
