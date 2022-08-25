# frozen_string_literal: true

class Filters::StatusesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_filter
  before_action :set_status_filters
  before_action :set_body_classes

  PER_PAGE = 20

  def index
    @status_filter_batch_action = Form::StatusFilterBatchAction.new
  end

  def batch
    @status_filter_batch_action = Form::StatusFilterBatchAction.new(status_filter_batch_action_params.merge(current_account: current_account, filter_id: params[:filter_id], type: action_from_button))
    @status_filter_batch_action.save!
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.statuses.no_status_selected')
  ensure
    redirect_to edit_filter_path(@filter)
  end

  private

  def set_filter
    @filter = current_account.custom_filters.find(params[:filter_id])
  end

  def set_status_filters
    @status_filters = @filter.statuses.preload(:status).page(params[:page]).per(PER_PAGE)
  end

  def status_filter_batch_action_params
    params.require(:form_status_filter_batch_action).permit(status_filter_ids: [])
  end

  def action_from_button
    if params[:remove]
      'remove'
    end
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
