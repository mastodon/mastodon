# frozen_string_literal: true

class LinkCrawlJob < ApplicationJob
  queue_as :default

  discard_on StandardError do |_job, error|
    Rails.logger.warn { "Job discarded: #{error} #{error.message} #{error.backtrace.join(' >> ')}" }
  end

  def perform(status_id)
    FetchLinkCardService.new.call(Status.find(status_id))
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
