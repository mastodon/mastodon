# frozen_string_literal: true

class UnblockDomainService < BaseService
  def call(domain_block, retroactive)
    if retroactive
      if domain_block.silence?
        Account.where(domain: domain_block.domain).update_all(silenced: false)
      else
        Account.where(domain: domain_block.domain).update_all(suspended: false)
      end
    end

    domain_block.destroy
  end
end
