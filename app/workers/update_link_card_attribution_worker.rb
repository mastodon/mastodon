# frozen_string_literal: true

class UpdateLinkCardAttributionWorker
  include Sidekiq::IterableJob

  def build_enumerator(account_id, cursor:)
    @account = Account.find_by(id: account_id)
    return if @account.blank?

    scope = PreviewCard.where(unverified_author_account: @account)
    active_record_batches_enumerator(scope, cursor:)
  end

  def each_iteration(preview_cards, account_id)
    preview_cards = preview_cards.filter do |preview_card|
      @account.can_be_attributed_from?(preview_card.domain)
    rescue Addressable::URI::InvalidURIError
      false
    end

    PreviewCard.where(id: preview_cards.pluck(:id), unverified_author_account: @account).update_all(author_account_id: account_id, unverified_author_account_id: nil)
  end
end
