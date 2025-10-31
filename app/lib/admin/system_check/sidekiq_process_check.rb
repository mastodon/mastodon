# frozen_string_literal: true

class Admin::SystemCheck::SidekiqProcessCheck < Admin::SystemCheck::BaseCheck
  SIDEKIQ_QUEUES = %w(
    default
    push
    mailers
    pull
    scheduler
    ingress
    fasp
  ).freeze

  def skip?
    !current_user.can?(:view_devops)
  end

  def pass?
    missing_queues.empty?
  end

  def message
    Admin::SystemCheck::Message.new(:sidekiq_process_check, missing_queues.join(', '))
  end

  private

  def missing_queues
    @missing_queues ||= Sidekiq::ProcessSet.new.reduce(SIDEKIQ_QUEUES) { |queues, process| queues - process['queues'] }
  end
end
