# frozen_string_literal: true

class Api::V1::Accounts::BaseController < Api::BaseController
  private

  def set_account
    @account = Account.kept.find(params[:account_id])
  end
end
