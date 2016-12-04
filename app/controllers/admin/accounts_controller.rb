# frozen_string_literal: true

class Admin::AccountsController < ApplicationController
  before_action :require_admin!
  before_action :set_account, except: :index

  layout 'public'

  def index
    @accounts = Account.order('domain ASC, username ASC').paginate(page: params[:page], per_page: 40)

    @accounts = @accounts.local                             if params[:local].present?
    @accounts = @accounts.remote                            if params[:remote].present?
    @accounts = @accounts.where(domain: params[:by_domain]) if params[:by_domain].present?
    @accounts = @accounts.where(silenced: true)             if params[:silenced].present?
    @accounts = @accounts.reorder('id desc')                if params[:recent].present?
  end

  def show; end

  def update
    if @account.update(account_params)
      redirect_to admin_accounts_path
    else
      render :show
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:silenced)
  end
end
