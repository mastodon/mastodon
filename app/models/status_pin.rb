# frozen_string_literal: true
# == Schema Information
#
# Table name: status_pins
#
#  id         :bigint           not null, primary key
#  account_id :bigint           not null
#  status_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StatusPin < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :status, required: true

  validates_with StatusPinValidator
end
