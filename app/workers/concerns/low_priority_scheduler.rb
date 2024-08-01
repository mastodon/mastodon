# frozen_string_literal: true

module LowPriorityScheduler
  # These are latency limits on various queues above which a server is
  # considered to be under load, causing the auto-deletion to be entirely
  # skipped for that run.
  LOAD_LATENCY_THRESHOLDS = {
    default: 5,
    push: 10,
    # The `pull` queue has lower priority jobs, and it's unlikely that
    # pushing deletes would cause much issues with this queue if it didn't
    # cause issues with `default` and `push`. Yet, do not enqueue deletes
    # if the instance is lagging behind too much.
    pull: 5.minutes.to_i,
  }.freeze

  def under_load?
    LOAD_LATENCY_THRESHOLDS.any? { |queue, max_latency| queue_under_load?(queue, max_latency) }
  end

  private

  def queue_under_load?(name, max_latency)
    Sidekiq::Queue.new(name).latency > max_latency
  end
end
