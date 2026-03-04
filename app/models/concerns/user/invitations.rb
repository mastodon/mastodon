# frozen_string_literal: true

module User::Invitations
  extend ActiveSupport::Concern

  included do
    belongs_to :invite, counter_cache: :uses, optional: true
    has_many :invites, inverse_of: :user, dependent: nil
    has_one :invite_request, class_name: 'UserInviteRequest', inverse_of: :user, dependent: :destroy

    validates :invite_request, presence: true, on: :create, if: :invite_text_required?
  end

  private

  def invite_text_required?
    Setting.require_invite_text && !open_registrations? && !invited? && !external? && !bypass_registration_checks?
  end
end
