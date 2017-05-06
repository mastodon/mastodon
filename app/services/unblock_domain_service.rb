# frozen_string_literal: true

class UnblockDomainService < BaseService
  def call(domain_block, retroactive)
    if retroactive
      accounts = Account.where(domain: domain_block.domain).in_batches

      if domain_block.silence?
        accounts.update_all(silenced: false)
      else
        accounts.update_all(suspended: false)
      end
    end

    domain_block.destroy
  end
end
