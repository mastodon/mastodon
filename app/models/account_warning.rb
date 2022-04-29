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
#

class AccountWarning < ApplicationRecord
  enum action: %i(none disable sensitive silence suspend), _suffix: :action

  belongs_to :account, inverse_of: :account_warnings
  belongs_to :target_account, class_name: 'Account', inverse_of: :targeted_account_warnings

  scope :latest, -> { order(created_at: :desc) }
  scope :custom, -> { where.not(text: '') }
end
