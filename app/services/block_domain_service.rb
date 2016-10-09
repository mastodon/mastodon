class BlockDomainService < BaseService
  def call(domain)
    block = DomainBlock.find_or_create_by!(domain: domain)

    Account.where(domain: domain).find_each do |account|
      if account.subscribed?
        account.subscription('').unsubscribe
      end

      account.destroy!
    end
  end
end
