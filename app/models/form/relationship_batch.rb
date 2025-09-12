# frozen_string_literal: true

class Form::RelationshipBatch < Form::BaseBatch
  attr_accessor :account_ids

  def save
    case action
    when 'follow'
      follow!
    when 'unfollow'
      unfollow!
    when 'remove_from_followers'
      remove_from_followers!
    when 'remove_domains_from_followers'
      remove_domains_from_followers!
    end
  end

  def persisted?
    true
  end

  private

  def follow!
    error = nil

    accounts.each do |target_account|
      FollowService.new.call(current_account, target_account)
    rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound => e
      error ||= e
    end

    raise error if error.present?
  end

  def unfollow!
    accounts.each do |target_account|
      UnfollowService.new.call(current_account, target_account)
    end
  end

  def remove_from_followers!
    RemoveFromFollowersService.new.call(current_account, account_ids)
  end

  def remove_domains_from_followers!
    RemoveDomainsFromFollowersService.new.call(current_account, account_domains)
  end

  def account_domains
    accounts.group(:domain).pluck(:domain).compact
  end

  def accounts
    Account.where(id: account_ids)
  end
end
