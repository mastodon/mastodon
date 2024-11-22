# frozen_string_literal: true

namespace :sidekiq_unique_jobs do
  task delete_all_locks: :environment do
    digests = SidekiqUniqueJobs::Digests.new
    digests.delete_by_pattern('*', count: digests.count)

    expiring_digests = SidekiqUniqueJobs::ExpiringDigests.new
    expiring_digests.delete_by_pattern('*', count: expiring_digests.count)
  end
end
