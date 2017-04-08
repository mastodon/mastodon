# frozen_string_literal: true

class RemoteProfileUpdateWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, body, resubscribe)
    account = Account.find(account_id)

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    author_container = xml.at_xpath('/xmlns:feed', xmlns: TagManager::XMLNS) || xml.at_xpath('/xmlns:entry', xmlns: TagManager::XMLNS)

    UpdateRemoteProfileService.new.call(author_container, account, resubscribe)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
