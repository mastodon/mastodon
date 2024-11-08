# frozen_string_literal: true

class PreviewCardsStatus < ApplicationRecord
  self.primary_key = [:preview_card_id, :status_id]

  belongs_to :preview_card
  belongs_to :status
end
