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

  def confirm
    wrap_email_confirmation do
      super
    end
  end

  # Mark current email as confirmed, bypassing Devise
  def mark_email_as_confirmed!
    wrap_email_confirmation do
      skip_confirmation!
      save!
    end
  end

  private

  def wrap_email_confirmation
    new_user = !confirmed?
    self.approved = true if grant_approval_on_confirmation?

    yield

    if new_user
      # Handle race condition when approving and confirming user at the same time
      reload unless approved?

      if approved?
        prepare_new_user!
      else
        notify_staff_about_pending_account!
      end
    end
  end
end
