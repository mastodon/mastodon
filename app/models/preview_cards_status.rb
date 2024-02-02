# frozen_string_literal: true

# == Schema Information
#
# Table name: preview_cards_statuses
#
#  preview_card_id :bigint(8)        not null, primary key
#  status_id       :bigint(8)        not null, primary key
#  url             :string
#
class PreviewCardsStatus < ApplicationRecord
  self.primary_key = [:preview_card_id, :status_id]

  belongs_to :preview_card
  belongs_to :status
end
