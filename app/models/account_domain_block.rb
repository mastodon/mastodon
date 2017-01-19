class AccountDomainBlock < ApplicationRecord

    belongs_to :account
    validates :target_domain, presence: true, uniqueness: true
    validates :account_id, uniqueness: {scope: :target_domain}

    # def self.blocked?(account, domain)
    #     where(domain: domain, account: account).exists?
    # end
end
