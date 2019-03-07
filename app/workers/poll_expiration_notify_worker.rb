# frozen_string_literal: true

class PollExpirationNotifyWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed

  def perform(poll_id)
    poll = Poll.find(poll_id)
    ActivityPub::DistributePollUpdateWorker.perform_async(poll.status.id)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
