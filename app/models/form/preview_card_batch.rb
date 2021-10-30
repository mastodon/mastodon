# frozen_string_literal: true

class Form::PreviewCardBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :preview_card_ids, :action, :current_account

  def save
    case action
    when 'approve'
      approve!
    when 'reject'
      reject!
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
    preview_card_providers.each do |provider|
      authorize(provider, :update?)
      provider.update(trendable: true, reviewed_at: action_time)
    end
  end

  def reject!
    preview_card_providers.each do |provider|
      authorize(provider, :update?)
      provider.update(trendable: false, reviewed_at: action_time)
    end
  end

  def action_time
    @action_time ||= Time.now.utc
  end
end
