# frozen_string_literal: true

class PollExpirationNotifyWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executing

  def perform(poll_id)
    @poll = Poll.find(poll_id)

    return if missing_expiration?
    requeue! && return if not_due_yet?

    notify_remote_voters_and_owner! if @poll.local?
    notify_local_voters!
  rescue ActiveRecord::RecordNotFound
    true
  end

  def self.remove_from_scheduled(poll_id)
    queue = Sidekiq::ScheduledSet.new
    queue.select { |scheduled| scheduled.klass == name && scheduled.args[0] == poll_id }.map(&:delete)
  end

  private

  def missing_expiration?
    @poll.expires_at.nil?
  end

  def not_due_yet?
    @poll.expires_at.present? && !@poll.expired?
  end

  def requeue!
    PollExpirationNotifyWorker.perform_at(@poll.expires_at + 5.minutes, @poll.id)
  end

  def notify_remote_voters_and_owner!
    ActivityPub::DistributePollUpdateWorker.perform_async(@poll.status.id)
    LocalNotificationWorker.perform_async(@poll.account_id, @poll.id, 'Poll', 'poll')
  end

  def notify_local_voters!
    @poll.voters.merge(Account.local).select(:id).find_in_batches do |accounts|
      LocalNotificationWorker.push_bulk(accounts) do |account|
        [account.id, @poll.id, 'Poll', 'poll']
      end
    end
  end
end
