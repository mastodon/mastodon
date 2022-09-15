# frozen_string_literal: true

module Admin
  class GroupStatusesController < BaseController
    before_action :set_group
    before_action :set_statuses

    PER_PAGE = 20

    def index
      authorize :status, :index?

      @status_batch_action = Admin::GroupStatusBatchAction.new
    end

    def batch
      authorize :status, :index?

      @status_batch_action = Admin::GroupStatusBatchAction.new(admin_group_status_batch_action_params.merge(current_account: current_account, report_id: params[:report_id], type: action_from_button))
      @status_batch_action.save!
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.statuses.no_status_selected')
    ensure
      redirect_to after_create_redirect_path
    end

    private

    def admin_group_status_batch_action_params
      params.require(:admin_group_status_batch_action).permit(status_ids: [])
    end

    def after_create_redirect_path
      report_id = @status_batch_action&.report_id || params[:report_id]
      if report_id.present?
        admin_report_path(report_id)
      else
        admin_group_statuses_path(params[:group_id], current_params)
      end
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    def set_statuses
      @statuses = Admin::GroupStatusFilter.new(@group, filter_params).results.preload(:application, :preloadable_poll, :media_attachments, active_mentions: :account, reblog: [:account, :application, :preloadable_poll, :media_attachments, active_mentions: :account]).page(params[:page]).per(PER_PAGE)
    end

    def filter_params
      params.slice(*Admin::StatusFilter::KEYS).permit(*Admin::StatusFilter::KEYS)
    end

    def current_params
      params.slice(:page).permit(:page)
    end

    def action_from_button
      if params[:report]
        'report'
      end
    end
  end
end
