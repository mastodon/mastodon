# frozen_string_literal: true
require 'csv'

class Export
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def to_blocked_accounts_csv
    to_csv account.blocking
  end

  def to_muted_accounts_csv
    to_csv account.muting
  end

  def to_following_accounts_csv
    to_csv account.following
  end

  def total_storage
    account.media_attachments.sum(:file_file_size)
  end

  def total_statuses
    account.statuses_count
  end

  def total_follows
    account.following_count
  end

  def total_followers
    account.followers_count
  end

  def total_blocks
    account.blocking.count
  end

  def total_mutes
    account.muting.count
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
