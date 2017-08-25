# frozen_string_literal: true
# == Schema Information
#
# Table name: status_pins
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  status_id  :integer          not null
#

class StatusPin < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :status, required: true

  validates_with StatusPinValidator
end
