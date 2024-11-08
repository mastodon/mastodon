# frozen_string_literal: true

class Marker < ApplicationRecord
  TIMELINES = %w(home notifications).freeze

  belongs_to :user

  validates :timeline, :last_read_id, presence: true
  validates :timeline, inclusion: { in: TIMELINES }
end
