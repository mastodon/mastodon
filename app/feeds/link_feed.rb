# frozen_string_literal: true

class LinkFeed < PublicFeed
  # @param [PreviewCard] preview_card
  # @param [Account] account
  # @param [Hash] options
  def initialize(preview_card, account, options = {})
    @preview_card = preview_card
    super(account, options)
  end

  # @param [Integer] limit
  # @param [Integer] max_id
  # @param [Integer] since_id
  # @param [Integer] min_id
  # @return [Array<Status>]
  def get(limit, max_id = nil, since_id = nil, min_id = nil)
    scope = public_scope

    scope.merge!(discoverable)
    scope.merge!(attached_to_preview_card)
    scope.merge!(account_filters_scope) if account?
    scope.merge!(language_scope) if account&.chosen_languages.present?

    scope.to_a_paginated_by_id(limit, max_id: max_id, since_id: since_id, min_id: min_id)
  end

  private

  def attached_to_preview_card
    Status.joins(:preview_cards_status).where(preview_cards_status: { preview_card_id: @preview_card.id })
  end

  def discoverable
    Account.discoverable
  end
end
