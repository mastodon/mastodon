# frozen_string_literal: true

class BlockService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    create_notification(block) unless target_account.local?
    block
  end

  private

  def create_notification(block)
    if block.target_account.ostatus?
      NotificationWorker.perform_async(build_xml(block), block.account_id, block.target_account_id)
    elsif block.target_account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(block), block.account_id, block.target_account.inbox_url)
    end
  end

  def build_json(block)
    ActiveModelSerializers::SerializableResource.new(
      block,
      serializer: ActivityPub::BlockSerializer,
      adapter: ActivityPub::Adapter
    ).to_json
  end

  def build_xml(block)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.block_salmon(block))
  end
end
