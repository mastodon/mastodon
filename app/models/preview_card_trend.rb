# frozen_string_literal: true

class PreviewCardTrend < ApplicationRecord
  include RankedTrend

  belongs_to :preview_card

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
end
