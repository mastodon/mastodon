# frozen_string_literal: true

module AccountSettableConcern
  extend ActiveSupport::Concern

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_local_account!
    @account = Account.find_local!(params[:account_username])
  end
end
