# frozen_string_literal: true

class GenerateAnnualReportWorker < ApplicationWorker
  def perform(account_id, year)
    AnnualReport.new(Account.find(account_id), year).generate
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordNotUnique
    true
  end
end
