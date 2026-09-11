# frozen_string_literal: true

class Admin::ModerationAction < Admin::BaseAction
  TYPES = %w(
    delete
    mark_as_sensitive
  ).freeze

  validates :report_id, presence: true

  private

  def status_ids
    report.status_ids
  end

  def statuses
    @statuses ||= Status.with_discarded.where(id: status_ids).reorder(nil)
  end

  def collections
    report.collections
  end

  def process_action!
    case type
    when 'delete'
      handle_delete!
    when 'mark_as_sensitive'
      handle_mark_as_sensitive!
    end
  end

  def handle_delete!
    statuses.each { |status| authorize([:admin, status], :destroy?) }
    collections.each { |collection| authorize([:admin, collection], :destroy?) }

    ApplicationRecord.transaction do
      delete_statuses!
      delete_collections!

      resolve_report!
      process_strike!(:delete_statuses)

      create_tombstones! unless target_account.local?
    end

    process_notification!

    RemovalWorker.push_bulk(status_ids) { |status_id| [status_id, { 'preserve' => target_account.local?, 'immediate' => !target_account.local? }] }
  end

  def handle_mark_as_sensitive!
    collections.each { |collection| authorize([:admin, collection], :update?) }

    # Can't use a transaction here because UpdateStatusService queues
    # Sidekiq jobs
    mark_statuses_as_sensitive!
    mark_collections_as_sensitive!

    resolve_report!
    process_strike!(:mark_statuses_as_sensitive)
    process_notification!
  end

  def delete_statuses!
    statuses.each do |status|
      status.discard_with_reblogs
      log_action(:destroy, status)
    end
  end

  def delete_collections!
    collections.each do |collection|
      collection.destroy!
      log_action(:destroy, collection)
    end
  end

  def create_tombstones!
    (statuses + collections).each { |record| Tombstone.find_or_create_by(uri: record.uri, account: target_account, by_moderator: true) }
  end

  def mark_statuses_as_sensitive!
    representative_account = Account.representative

    statuses.includes(:media_attachments, preview_cards_status: :preview_card).find_each do |status|
      next if status.discarded? || !(status.with_media? || status.with_preview_card?)

      authorize([:admin, status], :update?)

      if target_account.local?
        UpdateStatusService.new.call(status, representative_account.id, sensitive: true)
      else
        status.update(sensitive: true)
      end

      log_action(:update, status)
    end
  end

  def mark_collections_as_sensitive!
    collections.each do |collection|
      UpdateCollectionService.new.call(collection, sensitive: true)

      log_action(:update, collection)
    end
  end

  def resolve_report!
    report.resolve!(current_account)
    log_action(:resolve, report)
  end

  def target_account
    report.target_account
  end

  def text_for_warning = text
end
