# frozen_string_literal: true

# == Schema Information
#
# Table name: account_moderation_notes
#
#  id                :bigint(8)        not null, primary key
#  content           :text             not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountModerationNote < ApplicationRecord
  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  scope :chronological, -> { reorder(id: :asc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
end
