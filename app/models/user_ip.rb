# frozen_string_literal: true

class UserIp < ApplicationRecord
  include DatabaseViewRecord
  include InetContainer

  self.primary_key = :user_id

  belongs_to :user

  scope :by_latest_used, -> { order(used_at: :desc) }
end
