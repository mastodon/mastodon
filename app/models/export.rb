# frozen_string_literal: true
require 'csv'

class Export
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def to_blocked_accounts_csv
    to_csv @account.blocking
  end

  def to_muted_accounts_csv
    to_csv @account.muting
  end

  def to_following_accounts_csv
    to_csv @account.following
  end

  private

  def to_csv(accounts)
    CSV.generate do |csv|
      accounts.each do |account|
        csv << [(account.local? ? account.local_username_and_domain : account.acct)]
      end
    end
  end
end
