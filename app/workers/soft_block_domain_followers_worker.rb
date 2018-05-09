# frozen_string_literal: true

class SoftBlockDomainFollowersWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, domain)
    followers_id = Account.find(account_id).followers.where(domain: domain).pluck(:id)
    SoftBlockWorker.push_bulk(followers_id) do |follower_id|
      [account_id, follower_id]
    end
  end
end
