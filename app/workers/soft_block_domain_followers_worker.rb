# frozen_string_literal: true

class SoftBlockDomainFollowersWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, domain)
    Account.find(account_id).followers.where(domain: domain).pluck(:id).each do |follower_id|
      SoftBlockWorker.perform_async(account_id, follower_id)
    end
  end
end
