# frozen_string_literal: true

module User::Approval
  extend ActiveSupport::Concern

  included do
    scope :approved, -> { where(approved: true) }
    scope :pending, -> { where(approved: false) }
  end

  def pending?
    !approved?
  end
end
