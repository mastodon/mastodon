# frozen_string_literal: true

class MoveWorker
  include Sidekiq::Worker

  def perform(source_account_id, target_account_id)
    @source_account = Account.find(source_account_id)
    @target_account = Account.find(target_account_id)

    if @target_account.local?
      rewrite_follows!
    else
      queue_follow_unfollows!
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def rewrite_follows!
    @source_account.passive_relationships
                   .where(account: Account.local)
                   .in_batches
                   .update_all(target_account_id: @target_account.id)
  end

  def queue_follow_unfollows!
    @source_account.followers.local.select(:id).find_in_batches do |accounts|
      UnfollowFollowWorker.push_bulk(accounts.map(&:id)) { |follower_id| [follower_id, @source_account.id, @target_account.id] }
    end
  end
end
