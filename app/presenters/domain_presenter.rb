# frozen_string_literal: true

class DomainPresenter
  attr_accessor :domain

  def initialize(domain)
    @domain = domain
  end

  def accounts_count
    Account.where(domain: domain).count
  end

  def reports_count
    Report.joins(:target_account).where(accounts: { domain: domain }).count
  end

  def reported_accounts_count
    Account.joins(:targeted_reports).where(domain: domain).distinct.count
    # Report.joins(:target_account).where(accounts: { domain: domain }).distinct(:account).count
  end
end
