# frozen_string_literal: true

# == Schema Information
#
# Table name: announcement_mutes
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)
#  announcement_id :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AnnouncementMute < ApplicationRecord
  belongs_to :account
  belongs_to :announcement, inverse_of: :announcement_mutes

  validates :account_id, uniqueness: { scope: :announcement_id }
end
