# frozen_string_literal: true

module User::Confirmation
  extend ActiveSupport::Concern

  included do
    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :unconfirmed, -> { where(confirmed_at: nil) }
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end
end
