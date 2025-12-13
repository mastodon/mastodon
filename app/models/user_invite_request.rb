# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invite_requests
#
#  id         :bigint(8)        not null, primary key
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#

class UserInviteRequest < ApplicationRecord
  TEXT_SIZE_LIMIT = 420

  belongs_to :user, inverse_of: :invite_request
  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }
end
