# frozen_string_literal: true

class Form::PreviewCardBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :preview_card_ids, :action, :current_account, :precision

  def save
    case action
    when 'approve'
      approve!
    when 'approve_all'
      approve_all!
    when 'reject'
      reject!
    when 'reject_all'
      reject_all!
    end
  end

  private

  def preview_cards
    @preview_cards ||= PreviewCard.where(id: preview_card_ids)
  end

  def preview_card_providers
    @preview_card_providers ||= preview_cards.map(&:domain).uniq.map { |domain| PreviewCardProvider.matching_domain(domain) || PreviewCardProvider.new(domain: domain) }
  end

  def approve!
    preview_cards.each { |preview_card| authorize(preview_card, :update?) }
    preview_cards.update_all(trendable: true)
  end

  def approve_all!
    preview_card_providers.each do |provider|
      authorize(provider, :update?)
      provider.update(trendable: true, reviewed_at: action_time)
    end

    # Reset any individual overrides
    preview_cards.update_all(trendable: nil)
  end

  def reject!
    preview_cards.each { |preview_card| authorize(preview_card, :update?) }
    preview_cards.update_all(trendable: false)
  end

  def reject_all!
    preview_card_providers.each do |provider|
      authorize(provider, :update?)
      provider.update(trendable: false, reviewed_at: action_time)
    end

    # Reset any individual overrides
    preview_cards.update_all(trendable: nil)
  end

  def action_time
    @action_time ||= Time.now.utc
  end
end
