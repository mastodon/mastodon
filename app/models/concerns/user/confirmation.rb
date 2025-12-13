# frozen_string_literal: true

module User::Confirmation
  extend ActiveSupport::Concern

  included do
    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :unconfirmed, -> { where(confirmed_at: nil) }

    def confirm
      wrap_email_confirmation { super }
    end
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end
end
