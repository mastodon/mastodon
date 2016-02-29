class AccountsController < ApplicationController
  before_action :set_account

  def show
    respond_to do |format|
      format.html
      format.atom
    end
  end

  private

  def set_account
    @account = Account.find_by!(username: params[:username], domain: nil)
  end
end
