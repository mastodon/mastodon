# frozen_string_literal: true
# == Schema Information
#
# Table name: mentions
#
#  id         :integer          not null, primary key
#  account_id :integer
#  status_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  delivered  :boolean
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

  def set_delivered(delivery_status)
    self.delivered = delivery_status
    save!
  end
end
