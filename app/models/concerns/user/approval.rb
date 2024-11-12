# frozen_string_literal: true

module User::Approval
  extend ActiveSupport::Concern

  included do
    scope :approved, -> { where(approved: true) }
    scope :pending, -> { where(approved: false) }

    before_create :set_approved
  end

  def pending?
    !approved?
  end

  def approve!
    return if approved?

    update!(approved: true)

    # Handle scenario when approving and confirming a user at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end

  private

  def set_approved
    self.approved = begin
      if sign_up_from_ip_requires_approval? || sign_up_email_requires_approval?
        false
      else
        open_registrations? || valid_invitation? || external?
      end
    end
  end

  def grant_approval_on_confirmation?
    # Re-check approval on confirmation if the server has switched to open registrations
    open_registrations? && !sign_up_from_ip_requires_approval? && !sign_up_email_requires_approval?
  end

  def sign_up_from_ip_requires_approval?
    sign_up_ip.present? && IpBlock.severity_sign_up_requires_approval.containing(sign_up_ip.to_s).exists?
  end

  def sign_up_email_requires_approval?
    return false if email.blank?

    _, domain = email.split('@', 2)
    return false if domain.blank?

    records = []

    # Doing this conditionally is not very satisfying, but this is consistent
    # with the MX records validations we do and keeps the specs tractable.
    records = DomainResource.new(domain).mx unless self.class.skip_mx_check?

    EmailDomainBlock.requires_approval?(records + [domain], attempt_ip: sign_up_ip)
  end
end
