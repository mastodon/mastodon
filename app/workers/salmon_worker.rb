# frozen_string_literal: true

class SalmonWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', backtrace: true

  def perform(account_id, body)
    ProcessInteractionService.new.call(body, Account.find(account_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
