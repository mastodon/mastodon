# frozen_string_literal: true

# == Schema Information
#
# Table name: system_keys
#
#  id         :bigint(8)        not null, primary key
#  key        :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SystemKey < ApplicationRecord
  ROTATION_PERIOD = 1.week.freeze

  before_validation :set_key

  scope :expired, ->(now = Time.now.utc) { where(arel_table[:created_at].lt(now - (ROTATION_PERIOD * 3))) }

  class << self
    def current_key
      previous_key = order(id: :asc).last

      if previous_key && previous_key.created_at >= ROTATION_PERIOD.ago
        previous_key.key
      else
        create.key
      end
    end
  end

  private

  def set_key
    return if key.present?

    cipher = OpenSSL::Cipher.new('AES-256-GCM')
    cipher.encrypt

    self.key = cipher.random_key
  end
end
