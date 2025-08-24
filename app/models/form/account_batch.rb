# frozen_string_literal: true

class Form::AccountBatch < Form::BaseBatch
  include Payloadable

  attr_accessor :account_ids,
                :query,
                :select_all_matching

  def save
    case action
    when 'approve'
      approve!
    when 'reject'
      reject!
    when 'suspend'
      suspend!
    end
  end

  private

  def accounts
    if select_all_matching?
      query
    else
      Account.where(id: account_ids)
    end
  end

  def approve!
    accounts.includes(:user).find_each do |account|
      approve_account(account)
    end
  end

  def reject!
    accounts.includes(:user).find_each do |account|
      reject_account(account)
    end
  end

  def suspend!
    accounts.find_each do |account|
      if account.user_pending?
        reject_account(account)
      else
        suspend_account(account)
      end
    end
  end

  def reject_account(account)
    authorize(account.user, :reject?)
    log_action(:reject, account.user)
    account.suspend!(origin: :local)
    AccountDeletionWorker.perform_async(account.id, { 'reserve_username' => false })
  end

  def suspend_account(account)
    authorize(account, :suspend?)
    log_action(:suspend, account)
    account.suspend!(origin: :local)
    account.strikes.create!(
      account: current_account,
      action: :suspend
    )

    Admin::SuspensionWorker.perform_async(account.id)

    # Suspending a single account closes their associated reports, so
    # mass-suspending would be consistent.
    account.targeted_reports.unresolved.find_each do |report|
      authorize(report, :update?)
      log_action(:resolve, report)
      report.resolve!(current_account)
    rescue Mastodon::NotPermittedError
      # This should not happen, but just in case, do not fail early
    end
  end

  def approve_account(account)
    authorize(account.user, :approve?)
    log_action(:approve, account.user)
    account.user.approve!
  end

  def select_all_matching?
    select_all_matching == '1'
  end
end
