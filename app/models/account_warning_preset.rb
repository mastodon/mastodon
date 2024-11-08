# frozen_string_literal: true

class AccountWarningPreset < ApplicationRecord
  validates :text, presence: true

  scope :alphabetic, -> { order(title: :asc, text: :asc) }
end
