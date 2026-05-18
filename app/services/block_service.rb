# frozen_string_literal: true

class BlockService < BaseService
  include Payloadable

  def call(account, target_account)
    return if account.id == target_account.id

    @account = account
    @target_account = target_account

    handle_following_relationships
    handle_collections

    NotificationPermission.where(account: account, from_account: target_account).destroy_all

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    create_notification(block) if !target_account.local? && target_account.activitypub?
    block
  end

  private

  def handle_following_relationships
    UnfollowService.new.call(@account, @target_account) if @account.following?(@target_account)
    UnfollowService.new.call(@target_account, @account) if @target_account.following?(@account)
    RejectFollowService.new.call(@target_account, @account) if @target_account.requested?(@account)
  end

  def handle_collections
    # Remove account from target_account's collections
    @target_account.curated_collection_items.where(account: @account).find_each do |collection_item|
      RevokeCollectionItemService.new.call(collection_item)
    end

    # Remove target_account from account's collections
    @account.curated_collection_items.where(account: @target_account).find_each do |collection_item|
      DeleteCollectionItemService.new.call(collection_item)
    end
  end

  def create_notification(block)
    ActivityPub::DeliveryWorker.perform_async(build_json(block), block.account_id, block.target_account.inbox_url)
  end

  def build_json(block)
    serialize_payload(block, ActivityPub::BlockSerializer).to_json
  end
end
