# frozen_string_literal: true

class ResetUniqueJobsLocks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    # We do this to clean up unique job digests that were not properly
    # disposed of prior to https://github.com/mastodon/mastodon/pull/13361

    until SidekiqUniqueJobs::Digests.new.delete_by_pattern('*').nil?; end
  end

  def down; end
end
