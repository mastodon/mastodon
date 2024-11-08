# frozen_string_literal: true

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
