# frozen_string_literal: true

# == Schema Information
#
# Table name: custom_filter_statuses
#
#  id               :bigint(8)        not null, primary key
#  custom_filter_id :bigint(8)        not null
#  status_id        :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CustomFilterStatus < ApplicationRecord
  include CustomFilterCache

  belongs_to :custom_filter
  belongs_to :status

  validates :status, uniqueness: { scope: :custom_filter }
  validate :validate_status_access

  private

  def validate_status_access
    errors.add(:status_id, :invalid) unless StatusPolicy.new(custom_filter.account, status).show?
  end
end
