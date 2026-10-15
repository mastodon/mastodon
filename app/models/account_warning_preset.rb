# frozen_string_literal: true

# == Schema Information
#
# Table name: account_warning_presets
#
#  id              :bigint(8)        not null, primary key
#  action_category :string
#  text            :text             default(""), not null
#  title           :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AccountWarningPreset < ApplicationRecord
  ACTION_CATEGORIES = %w(suspend limit freeze sensitive warning appeal).freeze

  validates :text, presence: true
  validates :action_category, inclusion: { in: ACTION_CATEGORIES, allow_nil: true }

  scope :alphabetic, -> { order(title: :asc, text: :asc) }
end
