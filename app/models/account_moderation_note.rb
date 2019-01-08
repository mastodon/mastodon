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
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  scope :latest, -> { reorder('created_at DESC') }

  validates :content, presence: true, length: { maximum: 500 }
end
