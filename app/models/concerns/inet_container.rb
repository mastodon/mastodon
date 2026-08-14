# frozen_string_literal: true

module InetContainer
  extend ActiveSupport::Concern

  included do
    scope :containing, ->(value) { where('ip >>= ?', value) }
    scope :contained_by, ->(value) { where('ip <<= ?', value) }
    scope :overlapping_with, ->(value) { where('ip <<= :value OR ip >>= :value', value: value) }
  end
end
