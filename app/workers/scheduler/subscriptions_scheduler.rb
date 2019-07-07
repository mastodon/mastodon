# frozen_string_literal: true

class Scheduler::SubscriptionsScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform; end
end
