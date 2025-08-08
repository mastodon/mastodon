# frozen_string_literal: true

# == Schema Information
#
# Table name: announcement_mutes
#
#  id              :bigint(8)        not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint(8)        not null
#  announcement_id :bigint(8)        not null
#

class AnnouncementMute < ApplicationRecord
  with_options inverse_of: :announcement_mutes do
    belongs_to :account
    belongs_to :announcement
  end

  validates :account_id, uniqueness: { scope: :announcement_id }
end
