# frozen_string_literal: true

class UnblockService < BaseService
  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    create_notification(unblock) unless target_account.local?
    unblock
  end

  private

  def create_notification(unblock)
    if unblock.target_account.ostatus?
      NotificationWorker.perform_async(build_xml(unblock), unblock.account_id, unblock.target_account_id)
    elsif unblock.target_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(unblock), unblock.account_id, unblock.target_account.inbox_url)
    end
  end

  def build_json(unblock)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      unblock,
      serializer: ActivityPub::UndoBlockSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(unblock.account))
  end

  def build_xml(block)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.unblock_salmon(block))
  end
end
