# frozen_string_literal: true

module InetContainer
  extend ActiveSupport::Concern

  included do
    scope :containing, ->(value) { where('ip >>= ?', value) }
    scope :contained_by, ->(value) { where('ip <<= ?', value) }
  end
end
