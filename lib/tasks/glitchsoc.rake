namespace :glitchsoc do
  desc 'Backfill local-only flag on statuses table'
  task backfill_local_only: :environment do
    Status.local.where(local_only: nil).find_each do |st|
      ActiveRecord::Base.logger.silence { st.update_attribute(:local_only, st.marked_local_only?) }
    end
  end
end
