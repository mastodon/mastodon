# frozen_string_literal: true

class ProcessFeedService < BaseService
  def call(body, account)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    update_author(body, account)
    process_entries(xml, account)
  end

  private

  def update_author(body, account)
    RemoteProfileUpdateWorker.perform_async(account.id, body.force_encoding('UTF-8'), true)
  end

  def process_entries(xml, account)
    xml.xpath('//xmlns:entry', xmlns: TagManager::XMLNS).reverse_each.map { |entry| process_entry(entry, account) }.compact
  end

  def process_entry(xml, account)
    activity = OStatus::Activity::General.new(xml, account)
    activity.specialize&.perform if activity.status?
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Nothing was saved for #{activity.id} because: #{e}"
    nil
  end
end
