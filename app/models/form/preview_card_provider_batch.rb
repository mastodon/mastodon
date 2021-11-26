# frozen_string_literal: true

class Form::PreviewCardProviderBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :preview_card_provider_ids, :action, :current_account

  def save
    case action
    when 'approve'
      approve!
    when 'reject'
      reject!
    end
  end

  private

  def preview_card_providers
    PreviewCardProvider.where(id: preview_card_provider_ids)
  end

  def approve!
    preview_card_providers.each { |provider| authorize(provider, :update?) }
    preview_card_providers.update_all(trendable: true, reviewed_at: Time.now.utc)
  end

  def reject!
    preview_card_providers.each { |provider| authorize(provider, :update?) }
    preview_card_providers.update_all(trendable: false, reviewed_at: Time.now.utc)
  end
end
