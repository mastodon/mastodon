# frozen_string_literal: true

module Admin
  class StatusesController < BaseController
    before_action :set_account
    before_action :set_statuses, except: :show
    before_action :set_status, only: :show

    PER_PAGE = 20

    def index
      authorize [:admin, :status], :index?

      @status_batch_action = Admin::StatusBatchAction.new
    end

    def show
      authorize [:admin, @status], :show?

      @status_batch_action = Admin::StatusBatchAction.new
    end

    def batch
      authorize [:admin, :status], :index?

      @status_batch_action = Admin::StatusBatchAction.new(admin_status_batch_action_params.merge(current_account: current_account, report_id: params[:report_id], type: action_from_button))
      @status_batch_action.save!
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.statuses.no_status_selected')
    ensure
      redirect_to after_create_redirect_path
    end

    private

    def batched_ordered_status_edits
      @status.edits.includes(:account, status: [:account]).find_each(order: :asc)
    end
    helper_method :batched_ordered_status_edits

    def admin_status_batch_action_params
      params.require(:admin_status_batch_action).permit(status_ids: [])
    end

    def after_create_redirect_path
      report_id = @status_batch_action&.report_id || params[:report_id]

      if report_id.present?
        admin_report_path(report_id)
      else
        admin_account_statuses_path(params[:account_id], current_params)
      end
    end

    def set_account
      @account = Account.find(params[:account_id])
    end

    def set_status
      @status = @account.statuses.find(params[:id])
    end

    def set_statuses
      @statuses = Admin::StatusFilter.new(@account, filter_params).results.preload(:application, :preloadable_poll, :media_attachments, active_mentions: :account, reblog: [:account, :application, :preloadable_poll, :media_attachments, active_mentions: :account]).page(params[:page]).per(PER_PAGE)
    end

    def filter_params
      params.slice(*Admin::StatusFilter::KEYS).permit(*Admin::StatusFilter::KEYS)
    end

    def current_params
      params.slice(:media, :page).permit(:media, :page)
    end

    def action_from_button
      if params[:report]
        'report'
      elsif params[:remove_from_report]
        'remove_from_report'
      elsif params[:delete]
        'delete'
      end
    end
  end
end
