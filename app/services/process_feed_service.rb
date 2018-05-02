# frozen_string_literal: true

class ProcessFeedService < BaseService
  include XmlHelper

  def call(body, account, **options)
    @options = options

    xml = Oga.parse_xml(body)

    update_author(body, account)
    process_entries(xml, account)
  end

  private

  def update_author(body, account)
    RemoteProfileUpdateWorker.perform_async(account.id, body.force_encoding('UTF-8'), true)
  end

  def process_entries(xml, account)
    xml.xpath(namespaced_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS)).reverse_each.map { |entry| process_entry(entry, account) }.compact
  end

  def process_entry(xml, account)
    activity = OStatus::Activity::General.new(xml, account, @options)
    activity.specialize&.perform if activity.status?
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug "Nothing was saved for #{activity.id} because: #{e}"
    nil
  end
end
