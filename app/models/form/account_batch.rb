# frozen_string_literal: true

class Form::AccountBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :account_ids, :action, :current_account

  def save
    case action
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
    end
  end

  private

  def unfollow!
    accounts.find_each do |target_account|
      UnfollowService.new.call(current_account, target_account)
    end
  end

  def remove_from_followers!
    current_account.passive_relationships.where(account_id: account_ids).find_each do |follow|
      reject_follow!(follow)
    end
  end

  def block_domains!
    AfterAccountDomainBlockWorker.push_bulk(account_domains) do |domain|
      [current_account.id, domain]
    end
  end

  def account_domains
    accounts.pluck(Arel.sql('distinct domain')).compact
  end

  def accounts
    Account.where(id: account_ids)
  end

  def reject_follow!(follow)
    follow.destroy

    return unless follow.account.activitypub?

    json = ActiveModelSerializers::SerializableResource.new(
      follow,
      serializer: ActivityPub::RejectFollowSerializer,
      adapter: ActivityPub::Adapter
    ).to_json

    ActivityPub::DeliveryWorker.perform_async(json, current_account.id, follow.account.inbox_url)
  end

  def approve!
    users = accounts.includes(:user).map(&:user)

    users.each { |user| authorize(user, :approve?) }
         .each(&:approve!)
  end

  def reject!
    records = accounts.includes(:user)

    records.each { |account| authorize(account.user, :reject?) }
           .each { |account| SuspendAccountService.new.call(account, including_user: true, destroy: true, skip_distribution: true) }
  end
end
