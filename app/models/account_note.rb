# frozen_string_literal: true

class AccountNote < ApplicationRecord
  include RelationshipCacheable

  COMMENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }
  validates :comment, length: { maximum: COMMENT_SIZE_LIMIT }
end
