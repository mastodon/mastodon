# frozen_string_literal: true

class GenerateAnnualReportWorker
  include Sidekiq::Worker

  def perform(account_id, year)
    AnnualReport.new(Account.find(account_id), year).generate
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
