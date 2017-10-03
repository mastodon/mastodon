# frozen_string_literal: true

class BootstrapTimelineWorker
  include Sidekiq::Worker

  def perform(account_id)
    BootstrapTimelineService.new.call(Account.find(account_id))
  end
end
