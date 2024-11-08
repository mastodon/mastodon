# frozen_string_literal: true

class UserInviteRequest < ApplicationRecord
  TEXT_SIZE_LIMIT = 420

  belongs_to :user, inverse_of: :invite_request
  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }
end
