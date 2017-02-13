# frozen_string_literal: true

class BlockService < BaseService
  include StreamEntryRenderer

  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    NotificationWorker.perform_async(build_xml(block), account.id, target_account.id) unless target_account.local?
  end

  private

  def build_xml(block)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        unique_id xml, block.created_at, block.id, 'Block'
        title xml, "#{block.account.acct} no longer wishes to interact with #{block.target_account.acct}"

        author(xml) do
          include_author xml, block.account
        end

        object_type xml, :activity
        verb xml, :block

        target(xml) do
          include_author xml, block.target_account
        end
      end
    end.to_xml
  end
end
