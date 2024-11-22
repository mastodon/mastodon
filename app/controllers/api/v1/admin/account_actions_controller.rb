# frozen_string_literal: true

class Api::V1::Admin::AccountActionsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:accounts' }
  before_action :set_account

  after_action :verify_authorized

  def create
    authorize @account, :show?

    account_action                 = Admin::AccountAction.new(resource_params)
    account_action.target_account  = @account
    account_action.current_account = current_account
    account_action.save!

    render_empty
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def resource_params
    params.permit(
      :type,
      :report_id,
      :warning_preset_id,
      :text,
      :send_email_notification
    )
  end
end
