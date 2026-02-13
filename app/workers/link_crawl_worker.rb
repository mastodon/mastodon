# frozen_string_literal: true

class LinkCrawlWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 0

  def perform(status_id, url = nil)
    FetchLinkCardService.new.call(Status.find(status_id), url)
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
