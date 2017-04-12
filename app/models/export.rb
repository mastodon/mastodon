# frozen_string_literal: true
require 'csv'

class Export
  attr_reader :accounts

  def initialize(accounts)
    @accounts = accounts
  end

  def to_csv
    CSV.generate do |csv|
      accounts.each do |account|
        csv << [(account.local? ? account.local_username_and_domain : account.acct)]
      end
    end
  end
end
