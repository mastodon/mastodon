# frozen_string_literal: true

class Rule < ApplicationRecord
  include Discard::Model

  TEXT_SIZE_LIMIT = 300

  self.discard_column = :deleted_at

  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }

  scope :ordered, -> { kept.order(priority: :asc, id: :asc) }
end
