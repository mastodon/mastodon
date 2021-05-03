class ResetUniqueJobsLocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    # We do this to clean up unique job digests that were not properly
    # disposed of prior to https://github.com/tootsuite/mastodon/pull/13361

    SidekiqUniqueJobs::Digests.delete_by_pattern('*', count: SidekiqUniqueJobs::Digests.count)
  end

  def down; end
end
