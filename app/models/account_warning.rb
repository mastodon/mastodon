# frozen_string_literal: true
# == Schema Information
#
# Table name: account_warnings
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  target_account_id :bigint(8)
#  action            :integer          default("none"), not null
#  text              :text             default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  report_id         :bigint(8)
#  status_ids        :string           is an Array
#

class AccountWarning < ApplicationRecord
  enum action: {
    none:            0,
    disable:         1_000,
    delete_statuses: 1_500,
    sensitive:       2_000,
    silence:         3_000,
    suspend:         4_000,
  }, _suffix: :action

  belongs_to :account, inverse_of: :account_warnings
  belongs_to :target_account, class_name: 'Account', inverse_of: :strikes
  belongs_to :report, optional: true

  has_one :appeal, dependent: :destroy

  scope :latest, -> { order(id: :desc) }
  scope :custom, -> { where.not(text: '') }

  def statuses
    Status.with_discarded.where(id: status_ids || [])
  end
end
