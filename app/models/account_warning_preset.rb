# frozen_string_literal: true

# == Schema Information
#
# Table name: account_warning_presets
#
#  id              :bigint(8)        not null, primary key
#  action_category :string           default("all_actions"), not null
#  text            :text             default(""), not null
#  title           :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AccountWarningPreset < ApplicationRecord
  ACTIONS = (Admin::AccountAction::TYPES + ['all_actions']).freeze

  validates :text, presence: true
  validates :action_category, inclusion: { in: ACTIONS }

  scope :alphabetic, -> { order(title: :asc, text: :asc) }
end
