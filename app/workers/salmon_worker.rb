# frozen_string_literal: true

class SalmonWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true

  def perform(account_id, body); end
end
