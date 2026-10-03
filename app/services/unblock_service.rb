# frozen_string_literal: true

class UnblockService < BaseService
  include Payloadable

  def call(account, target_account)
    return unless account.blocking?(target_account)

    ApplicationRecord.transaction do
      @unblock = account.unblock!(target_account)

      relay = Relay.find_by(account: target_account)

      RelayPreference.upsert({ relay_id: relay.id, account_id: account.id, enabled: true }, unique_by: %w(account_id relay_id)) if relay
    end

    create_notification(@unblock) if !target_account.local? && target_account.activitypub?
    @unblock
  end

  private

  def create_notification(unblock)
    ActivityPub::DeliveryWorker.perform_async(build_json(unblock), unblock.account_id, unblock.target_account.inbox_url)
  end

  def build_json(unblock)
    serialize_payload(unblock, ActivityPub::UndoBlockSerializer).to_json
  end
end
