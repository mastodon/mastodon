# frozen_string_literal: true

namespace :glitchsoc do
  desc 'Backfill local-only flag on statuses table'
  task backfill_local_only: :environment do
    Status.local.where(local_only: nil).find_each do |status|
      ActiveRecord::Base.logger.silence do
        status.update_attribute(:local_only, status.marked_local_only?)
      end
    end
  end
end
