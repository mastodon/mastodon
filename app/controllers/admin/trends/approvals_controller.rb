# frozen_string_literal: true

class Admin::Trends::ApprovalsController < Admin::BaseController
  def create
    authorize account, :review?
    account.update(trendable: true, reviewed_at: Time.now.utc)

    redirect_to admin_account_path(account.id)
  end

  def destroy
    authorize account, :review?
    account.update(trendable: false, reviewed_at: Time.now.utc)

    redirect_to admin_account_path(account.id)
  end

  private

  def account
    @account ||= Account.find(params[:account_id])
  end
end
