# frozen_string_literal: true
# == Schema Information
#
# Table name: mentions
#
#  status_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer
#  id         :integer          not null, primary key
#

class Mention < ApplicationRecord
  belongs_to :account, inverse_of: :mentions, required: true
  belongs_to :status, required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, uniqueness: { scope: :status }

  delegate(
    :username,
    :acct,
    to: :account,
    prefix: true
  )
end
