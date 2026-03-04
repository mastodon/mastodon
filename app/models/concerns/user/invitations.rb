# frozen_string_literal: true

module User::Invitations
  extend ActiveSupport::Concern

  included do
    belongs_to :invite, counter_cache: :uses, optional: true
    has_many :invites, inverse_of: :user, dependent: nil
    has_one :invite_request, class_name: 'UserInviteRequest', inverse_of: :user, dependent: :destroy
  end
end
