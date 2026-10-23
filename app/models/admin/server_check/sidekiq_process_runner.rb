# frozen_string_literal: true

class Admin::ServerCheck::SidekiqProcessRunner
  include Admin::ServerCheck::Runner

  SIDEKIQ_QUEUES = %w(
    default
    push
    mailers
    pull
    scheduler
    ingress
    fasp
  ).freeze

  def async?
    false
  end

  def authorized?(user)
    user.can?(:view_devops)
  end

  def run
    missing_queues = Sidekiq::ProcessSet.new.reduce(SIDEKIQ_QUEUES) { |queues, process| queues - process['queues'] }
    missing_queues.empty? ? ok : pending(data: { missing_queues:, missing_queues_str: missing_queues.join(', ') })
  end
end
