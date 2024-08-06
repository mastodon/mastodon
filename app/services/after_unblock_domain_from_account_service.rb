# frozen_string_literal: true

class AfterUnblockDomainFromAccountService < BaseService
  include Redisable

  # This service does not delete an AccountDomainBlock record,
  # it's meant to be called after such a record has been created
  # synchronously, to "clean up"
  def call(account, domain)
    redis.publish('system', Oj.dump(event: :domain_blocks_changed, account: account.id, target_domain: domain))
  end
end
