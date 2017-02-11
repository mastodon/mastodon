# frozen_string_literal: true

class UnblockService < BaseService
  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    NotificationWorker.perform_async(build_xml(unblock), account.id, target_account.id) unless target_account.local?
  end

  private

  def build_xml(block)
    Nokogiri::XML::Builder.new do |xml|
      entry(xml, true) do
        title xml, "#{block.account.acct} no longer blocks #{block.target_account.acct}"

        author(xml) do
          include_author xml, block.account
        end

        object_type xml, :activity
        verb xml, :unblock

        target(xml) do
          include_author xml, block.target_account
        end
      end
    end.to_xml
  end
end
