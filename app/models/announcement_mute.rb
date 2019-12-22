# frozen_string_literal: true

class AnnouncementMute < ApplicationRecord
  belongs_to :account
  belongs_to :announcement

  validates :account_id, uniqueness: { scope: :announcement_id }
end
