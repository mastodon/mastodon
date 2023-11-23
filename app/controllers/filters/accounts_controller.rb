# frozen_string_literal: true

class Filters::AccountsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_filter
  before_action :set_account_filters
  before_action :set_body_classes
  before_action :set_cache_headers

  PER_PAGE = 20

  def index
    @account_filter_batch_action = Form::AccountFilterBatchAction.new
  end

  def batch
    @account_filter_batch_action = Form::AccountFilterBatchAction.new(account_filter_batch_action_params.merge(current_account: current_account, filter_id: params[:filter_id], type: action_from_button))
    @account_filter_batch_action.save!
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.accounts.no_account_selected')
  ensure
    redirect_to edit_filter_path(@filter)
  end

  private

  def set_filter
    @filter = current_account.custom_filters.find(params[:filter_id])
  end

  def set_account_filters
    @account_filters = @filter.accounts.preload(:target_account).page(params[:page]).per(PER_PAGE)
  end

  def account_filter_batch_action_params
    params.require(:form_account_filter_batch_action).permit(account_filter_ids: [])
  end

  def action_from_button
    'remove' if params[:remove]
  end

  def set_body_classes
    @body_classes = 'admin'
  end

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
