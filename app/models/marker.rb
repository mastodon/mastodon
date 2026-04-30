# frozen_string_literal: true

# == Schema Information
#
# Table name: markers
#
#  id           :bigint(8)        not null, primary key
#  lock_version :integer          default(0), not null
#  timeline     :string           default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  last_read_id :bigint(8)        default(0), not null
#  user_id      :bigint(8)        not null
#

class Marker < ApplicationRecord
  TIMELINES = %w(home notifications).freeze

  belongs_to :user

  validates :timeline, :last_read_id, presence: true
  validates :timeline, inclusion: { in: TIMELINES }

  def self.record(user, pairs)
    {}.tap do |markers|
      transaction do
        pairs.each_pair do |timeline, params|
          markers[timeline] = user.markers.find_or_create_by(timeline:)
          markers[timeline].update!(params)
        end
      end
    end
  end
end
