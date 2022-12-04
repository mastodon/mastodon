# frozen_string_literal: true

class Trends::StatusBatch
  include ActiveModel::Model
  include Authorization

  attr_accessor :status_ids, :action, :current_account

  def save
    case action
    when 'approve'
      approve!
    when 'approve_accounts'
      approve_accounts!
    when 'reject'
      reject!
    when 'reject_accounts'
      reject_accounts!
    end
  end

  private

  def statuses
    @statuses ||= Status.where(id: status_ids)
  end

  def status_accounts
    @status_accounts ||= Account.where(id: statuses.map(&:account_id).uniq)
  end

  def approve!
    statuses.each { |status| authorize([:admin, status], :review?) }
    statuses.update_all(trendable: true)
  end

  def approve_accounts!
    status_accounts.each do |account|
      authorize(account, :review?)
      account.update(trendable: true, reviewed_at: action_time)
    end

    # Reset any individual overrides
    statuses.update_all(trendable: nil)
  end

  def reject!
    statuses.each { |status| authorize([:admin, status], :review?) }
    statuses.update_all(trendable: false)
  end

  def reject_accounts!
    status_accounts.each do |account|
      authorize(account, :review?)
      account.update(trendable: false, reviewed_at: action_time)
    end

    # Reset any individual overrides
    statuses.update_all(trendable: nil)
  end

  def action_time
    @action_time ||= Time.now.utc
  end
end
