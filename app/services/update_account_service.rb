# frozen_string_literal: true

class UpdateAccountService < BaseService
  PREVIEW_CARD_REATTRIBUTION_LIMIT = 1_000

  def call(account, params, raise_error: false)
    was_locked    = account.locked
    update_method = raise_error ? :update! : :update

    account.send(update_method, params).tap do |ret|
      next unless ret

      authorize_all_follow_requests(account) if was_locked && !account.locked
      check_links(account)
      process_hashtags(account)
      process_attribution_domains(account)
    end
  rescue Mastodon::DimensionsValidationError, Mastodon::StreamValidationError => e
    account.errors.add(:avatar, e.message)
    false
  end

  private

  def authorize_all_follow_requests(account)
    follow_requests = FollowRequest.where(target_account: account)
    follow_requests = follow_requests.preload(:account).reject { |req| req.account.silenced? }
    AuthorizeFollowWorker.push_bulk(follow_requests, limit: 1_000) do |req|
      [req.account_id, req.target_account_id]
    end
  end

  def check_links(account)
    return unless account.fields.any?(&:requires_verification?)

    VerifyAccountLinksWorker.perform_async(account.id)
  end

  def process_hashtags(account)
    account.tags_as_strings = Extractor.extract_hashtags(account.note)
  end

  def process_attribution_domains(account)
    return unless account.attribute_previously_changed?(:attribution_domains)

    # Go through the most recent cards, and do the rest in a background job
    preview_cards = PreviewCard.where(unverified_author_account: account).reorder(id: :desc).limit(PREVIEW_CARD_REATTRIBUTION_LIMIT).to_a
    should_queue_worker = preview_cards.size == PREVIEW_CARD_REATTRIBUTION_LIMIT

    preview_cards = preview_cards.filter do |preview_card|
      account.can_be_attributed_from?(preview_card.domain)
    rescue Addressable::URI::InvalidURIError
      false
    end

    PreviewCard.where(id: preview_cards.pluck(:id), unverified_author_account: account).update_all(author_account_id: account.id, unverified_author_account_id: nil)

    UpdateLinkCardAttributionWorker.perform_async(account.id) if should_queue_worker
  end
end
