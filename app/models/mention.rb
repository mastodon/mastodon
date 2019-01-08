# frozen_string_literal: true
# == Schema Information
#
# Table name: mentions
#
#  id         :bigint(8)        not null, primary key
#  status_id  :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)
#

class Mention < ApplicationRecord
  belongs_to :account, inverse_of: :mentions
  belongs_to :status

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, uniqueness: { scope: :status }

  delegate(
    :username,
    :acct,
    to: :account,
    prefix: true
  )
end
