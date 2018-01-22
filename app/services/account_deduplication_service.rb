# frozen_string_literal: true

class AccountDeduplicationService < BaseService
  def call(reference_account)
    Account.where.not(id: reference_account.id).where(uri: reference_account.uri).each do |account|
      if account.protocol == reference_account.protocol && account.public_key == reference_account.public_key
        # The accounts are functionnaly the same, merge them
        merge_accounts(reference_account, account)
      end
      account.destroy
    end
  end

  private

  def merge_accounts(reference_account, account)
    ActiveRecord.transaction do
      # Re-attribute statuses
      account.statuses.find_each do |status|
        status.account = reference_account
        status.save
      end

      # Re-attribute favourites
      account.favourites.find_each do |fav|
        fav.account = reference_account
        fav.save
      end

      # Re-attribute mentions
      account.mentions.find_each do |mention|
        mention.account = reference_account
        mention.save
      end

      # Re-follow reference account
      account.followers.where(domain: nil).find_each do |follower|
        # Schedule re-follow
        begin
          FollowService.new.call(follower, reference_account)
        rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound, Mastodon::UnexpectedResponseError, HTTP::Error, OpenSSL::SSL::SSLError
          next
        end
      end
    end
  end
end
