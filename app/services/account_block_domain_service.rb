# frozen_string_literal: true

class AccountBlockDomainService < BaseService
  def call(account, domain)
    return if account.blocking_domain?(domain)
    account.block_domain!(domain)

    account.followers.where(domain: domain).each do |follower|
      UnfollowService.new.call(follower, account)
    end

    account.following.where(domain: domain).each do |following|
      UnfollowService.new.call(account, following)
    end

    Account.where(domain: domain).each do |target_account|
      BlockWorker.perform_async(account.id, target_account.id)
    end
  end
end
