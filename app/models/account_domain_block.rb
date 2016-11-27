# frozen_string_literal: true

class AccountDomainBlock < ApplicationRecord
  belongs_to :account
  validates :domain, presence: true, uniqueness: true

  validates :account_id, uniqueness: { scope: :domain }

  def self.blocked?(account, domain)
    where(domain: domain, account: account).exists?
  end
end
