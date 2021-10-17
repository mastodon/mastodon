# frozen_string_literal: true

class Form::AccountBatch
  include ActiveModel::Model
  include Authorization
  include Payloadable

  attr_accessor :account_ids, :action, :current_account

  def save
    case action
    when 'follow'
      follow!
    when 'unfollow'
      unfollow!
    when 'remove_from_followers'
      remove_from_followers!
    when 'block_domains'
      block_domains!
    when 'approve'
      approve!
    when 'reject'
      reject!
    when 'suppress_follow_recommendation'
      suppress_follow_recommendation!
    when 'unsuppress_follow_recommendation'
      unsuppress_follow_recommendation!
    end
  end

  private

  def follow!
    accounts.find_each do |target_account|
      FollowService.new.call(current_account, target_account)
    end
  end

  def unfollow!
    accounts.find_each do |target_account|
      UnfollowService.new.call(current_account, target_account)
    end
  end

  def remove_from_followers!
    RemoveFromFollowersService.new.call(current_account, account_ids)
  end

  def block_domains!
    AfterAccountDomainBlockWorker.push_bulk(account_domains) do |domain|
      [current_account.id, domain]
    end
  end

  def account_domains
    accounts.group(:domain).pluck(:domain).compact
  end

  def accounts
    Account.where(id: account_ids)
  end

  def approve!
    users = accounts.includes(:user).map(&:user)

    users.each { |user| authorize(user, :approve?) }
         .each(&:approve!)
  end

  def reject!
    records = accounts.includes(:user)

    records.each { |account| authorize(account.user, :reject?) }
           .each { |account| DeleteAccountService.new.call(account, reserve_email: false, reserve_username: false) }
  end

  def suppress_follow_recommendation!
    authorize(:follow_recommendation, :suppress?)

    accounts.each do |account|
      FollowRecommendationSuppression.create(account: account)
    end
  end

  def unsuppress_follow_recommendation!
    authorize(:follow_recommendation, :unsuppress?)

    FollowRecommendationSuppression.where(account_id: account_ids).destroy_all
  end
end
