# frozen_string_literal: true

class Api::V1::Admin::StatusActionsController < Api::BaseController
  include Authorization

  # only support a subset of StatusBatchAction types
  ALLOWED_TYPES = %w(
    delete
    sensitive
  ).freeze

  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:statuses' }
  before_action :set_status

  after_action :verify_authorized

  def create
    authorize [:admin, @status], :update?
    raise ActiveRecord::RecordInvalid unless valid_type?

    status_batch_action                 = Admin::StatusBatchAction.new(resource_params)
    status_batch_action.status_ids      = [@status.id]
    status_batch_action.current_account = current_account
    status_batch_action.save!

    render_empty
  end

  private

  def valid_type?
    params[:type] && ALLOWED_TYPES.include?(params[:type])
  end

  def set_status
    @status = Status.find(params[:status_id])
  end

  def resource_params
    params.permit(
      :type,
      :report_id,
      :text,
      :send_email_notification
    )
  end
end
