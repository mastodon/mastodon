# frozen_string_literal: true
# == Schema Information
#
# Table name: user_notes
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  target_account_id :bigint(8)
#  comment           :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class UserNote < ApplicationRecord
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }
end
