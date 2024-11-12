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

  def approve!
    return if approved?

    update!(approved: true)

    # Handle scenario when approving and confirming a user at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end
end
