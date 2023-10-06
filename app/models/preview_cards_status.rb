# frozen_string_literal: true

# == Schema Information
#
# Table name: preview_cards_statuses
#
#  preview_card_id :bigint(8)        not null
#  status_id       :bigint(8)        not null
#  url             :string
#
class PreviewCardsStatus < ApplicationRecord
  # Composite primary keys are not properly supported in Rails. However,
  # we shouldn't need this anyway...
  self.primary_key = nil

  belongs_to :preview_card
  belongs_to :status
end
