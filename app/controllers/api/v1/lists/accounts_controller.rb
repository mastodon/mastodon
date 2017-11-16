# frozen_string_literal: true

class Api::V1::Lists::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!
  before_action :set_list

  def show
    render json: @list.accounts, each_serializer: REST::AccountSerializer
  end

  def create
    ApplicationRecord.transaction do
      list_accounts.each do |account|
        @list.accounts << account
      end
    end

    render_empty
  end

  def destroy
    ListAccount.where(list: @list, account_id: account_ids).destroy_all
    render_empty
  end

  private

  def set_list
    @list = List.where(account: current_account).find(params[:list_id])
  end

  def list_accounts
    Account.find(account_ids)
  end

  def account_ids
    Array(resource_params[:account_ids])
  end

  def resource_params
    params.permit(account_ids: [])
  end
end
