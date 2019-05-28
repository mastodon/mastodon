# frozen_string_literal: true

# == Schema Information
#
# Table name: account_warning_presets
#
#  id         :bigint(8)        not null, primary key
#  text       :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AccountWarningPreset < ApplicationRecord
  validates :text, presence: true
end
