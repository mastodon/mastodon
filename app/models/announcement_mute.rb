# frozen_string_literal: true

class AnnouncementMute < ApplicationRecord
  belongs_to :account
  belongs_to :announcement, inverse_of: :announcement_mutes

  validates :account_id, uniqueness: { scope: :announcement_id }
end
