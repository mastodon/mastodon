# frozen_string_literal: true
# == Schema Information
#
# Table name: status_pins
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  status_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StatusPin < ApplicationRecord
  belongs_to :account
  belongs_to :status

  validates_with StatusPinValidator
end
