# frozen_string_literal: true

class GenerateAnnualReportWorker
  include Sidekiq::Worker

  def perform(account_id, year)
    async_refresh = AsyncRefresh.new("wrapstodon:#{account_id}:#{year}")

    AnnualReport.new(Account.find(account_id), year).generate

    async_refresh&.finish!
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
