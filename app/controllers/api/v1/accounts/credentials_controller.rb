# frozen_string_literal: true

class Api::V1::Accounts::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: [:update]
  before_action :require_user!

  def show
    @account = current_account
    @plain_text_note = query_params[:note_format] == 'plain'
    render 'api/v1/accounts/show'
  end

  def update
    current_account.update!(account_params)
    @account = current_account
    render 'api/v1/accounts/show'
  end

  private

  def account_params
    params.permit(:display_name, :note, :avatar, :header)
  end

  def query_params
    params.permit(:note_format)
  end
end
